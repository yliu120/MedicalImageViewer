package main

import (
	"bytes"
	"encoding/base64"
	"encoding/json"
	"flag"
	"log"
	"os"
	"sync"
	"time"

	openapi "github.com/alibabacloud-go/darabonba-openapi/v2/client"
	eci "github.com/alibabacloud-go/eci-20180808/v3/client"
	tea "github.com/alibabacloud-go/tea-utils/v2/service"
	vpc_utils "github.com/yliu120/MedicalImageViewer/aliyun/vpc"
)

type CreateContainerGroupConf struct {
	// Schema for `openapi.Config`
	// pkg.go.dev/github.com/alibabacloud-go/darabonba-openapi/v2/client#Config
	Client openapi.Config
	// Schema for `CreateContainerGroupRequest`
	// pkg.go.dev/github.com/alibabacloud-go/eci-20180808/v3/client#CreateContainerGroupRequest
	ContainerGroup eci.CreateContainerGroupRequest
}

var (
	logInfo    *log.Logger
	logError   *log.Logger
	logFatal   *log.Logger
	monitoring bool
)

func init() {
	logInfo = log.New(os.Stdout, "INFO: ", log.Ldate|log.Ltime|log.Lshortfile)
	logError = log.New(os.Stderr, "ERROR: ", log.Ldate|log.Ltime|log.Lshortfile)
	logFatal = log.New(os.Stderr, "FATAL: ", log.Ldate|log.Ltime|log.Lshortfile)
}

func loadAndFillConfigFileContent(conf *CreateContainerGroupConf, eipAddr []byte) {
	confVols := []*eci.CreateContainerGroupRequestVolumeConfigFileVolume{}
	for _, vol := range conf.ContainerGroup.Volume {
		if vol != nil && *vol.Type == "ConfigFileVolume" {
			confVols = append(confVols, vol.ConfigFileVolume)
		}
	}
	if len(confVols) == 0 {
		logError.Println("ConfigFileVolumes not provided.")
		return
	}

	var wg sync.WaitGroup
	wg.Add(len(confVols))

	loadContentFromFile := func(path *string) string {
		defer wg.Done()

		bs, err := os.ReadFile(*path)
		bs = bytes.ReplaceAll(bs, []byte("localhost"), eipAddr)
		if err != nil {
			logFatal.Fatalf("Unable to read file: %s", *path)
		}
		// Aliyun needs base64 encoding for config files.
		return base64.StdEncoding.EncodeToString(bs)
	}

	for i, p := range confVols {
		if len(p.ConfigFileToPath) == 0 {
			logError.Printf("The %d-th config file is empty.", i)
			continue
		}
		var cfp = p.ConfigFileToPath[0]
		// !!! Hack !!!
		// The passed-in Json ConfigFileToPath.Content is the local path
		// of the config file.
		cfp.SetContent(loadContentFromFile(cfp.Content))
	}
}

func deploy(eciClient *eci.Client, conf *CreateContainerGroupConf, dryRun bool) {
	ropts := new(tea.RuntimeOptions).SetAutoretry(false)

	eipResp := vpc_utils.AllocateEipAddress(&conf.Client, dryRun)
	if eipResp == nil {
		logFatal.Fatalln("Unable to create EIP. Exit.")
	}

	conf.ContainerGroup.SetEipInstanceId(*eipResp.Body.AllocationId)
	loadAndFillConfigFileContent(conf, []byte(*eipResp.Body.EipAddress))
	logInfo.Println("CreateContainerGroupRequest: ", conf.ContainerGroup.GoString())

	if dryRun {
		logInfo.Printf("Please visit: http://%s/ for accessing the viewer.", *eipResp.Body.EipAddress)
		return
	}

	response, err := eciClient.CreateContainerGroupWithOptions(&conf.ContainerGroup, ropts)
	if err != nil {
		logFatal.Fatalln("Failed to create container group request: ", err)
	}

	logInfo.Println("Response Body: ", response.GoString())
	logInfo.Printf("Please visit: http://%s/ for accessing the viewer.", *eipResp.Body.EipAddress)
	if !monitoring {
		return
	}

	req := new(eci.DescribeContainerGroupStatusRequest).SetRegionId(
		*eciClient.RegionId).SetContainerGroupIds(
		*response.Body.ContainerGroupId)

	for {
		time.Sleep(10 * time.Second)
		resp, err := eciClient.DescribeContainerGroupStatus(req)
		if err != nil {
			logError.Println("Unable to monitor container group.")
		}
		var respData = resp.Body.Data[0]
		logInfo.Println("Container group status: ", respData.GoString())
	}
}

func main() {
	confPtr := flag.String("conf", "deploy.json", "Configuration for deployment.")
	flag.BoolVar(&monitoring, "mon", false, "Periodically monitoring the status of the group.")
	dryRun := flag.Bool("dry_run", false, "If true, simply print the create request and exit.")
	flag.Parse()

	bytes, err := os.ReadFile(*confPtr)
	if err != nil {
		logFatal.Fatalf("Cannot read configuration file[%s]: %s", *confPtr, err)
	}

	var conf CreateContainerGroupConf
	err = json.Unmarshal(bytes, &conf)
	if err != nil {
		logFatal.Fatalln("Unable to parse configuration file.", err)
	}

	conf.Client.SetEndpoint("eci." + *conf.Client.RegionId + ".aliyuncs.com").SetType("access_key")
	logInfo.Println("conf: ", conf.Client)

	eciClient, err := eci.NewClient(&conf.Client)
	if err != nil {
		logFatal.Fatalln("Unable to create ECI client with config:", err)
	}
	deploy(eciClient, &conf, *dryRun)
}
