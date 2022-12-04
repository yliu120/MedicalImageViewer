package vpc

import (
	"log"
	"os"

	openapi "github.com/alibabacloud-go/darabonba-openapi/v2/client"
	tea "github.com/alibabacloud-go/tea-utils/v2/service"
	vpc "github.com/alibabacloud-go/vpc-20160428/v2/client"
)

var (
	logInfo  *log.Logger
	logError *log.Logger
)

func init() {
	logInfo = log.New(os.Stdout, "INFO: ", log.Ldate|log.Ltime|log.Lshortfile)
	logError = log.New(os.Stderr, "ERROR: ", log.Ldate|log.Ltime|log.Lshortfile)
}

func AllocateEipAddress(clientConfig *openapi.Config, dryRun bool) *vpc.AllocateEipAddressResponse {
	if dryRun {
		return fakeAllocateEipResponse()
	}

	if clientConfig == nil {
		logError.Println("Unable to create EIP address with a null client config.")
		return nil
	}

	// TODO: Extract to a init func.
	vpcClientConfig := &openapi.Config{}
	vpcClientConfig.SetAccessKeyId(*clientConfig.AccessKeyId)
	vpcClientConfig.SetAccessKeySecret(*clientConfig.AccessKeySecret)
	vpcClientConfig.SetRegionId(*clientConfig.RegionId)
	vpcClient, err := vpc.NewClient(vpcClientConfig)
	if err != nil {
		logError.Println("Unable to create a VPC client.", err)
		return nil
	}

	allocateEipAddressReq := &vpc.AllocateEipAddressRequest{}
	allocateEipAddressReq.SetBandwidth("200")
	allocateEipAddressReq.SetName("MedicalImageViewer")
	allocateEipAddressReq.SetInternetChargeType("PayByTraffic")
	runtime := &tea.RuntimeOptions{}

	resp, err := vpcClient.AllocateEipAddressWithOptions(allocateEipAddressReq, runtime)
	if err != nil {
		logError.Println("Fail to create AllocateEipAddress.", err)
	}
	logInfo.Printf("Got AllocateEipAddressResponse: %s", resp.GoString())
	return resp
}

func ReleaseEipAddress(clientConfig *openapi.Config,
	allocationId *string, dryRun bool) *vpc.ReleaseEipAddressResponse {
	if dryRun {
		return nil
	}

	vpcClientConfig := &openapi.Config{}
	vpcClientConfig.SetAccessKeyId(*clientConfig.AccessKeyId)
	vpcClientConfig.SetAccessKeySecret(*clientConfig.AccessKeySecret)
	vpcClientConfig.SetRegionId(*clientConfig.RegionId)

	vpcClient, err := vpc.NewClient(vpcClientConfig)
	if err != nil {
		logError.Println("Unable to create a VPC client.", err)
		return nil
	}

	releaseEipAddressReq := &vpc.ReleaseEipAddressRequest{}
	releaseEipAddressReq.SetAllocationId(*allocationId)
	releaseEipAddressReq.SetRegionId(*clientConfig.RegionId)

	runtime := &tea.RuntimeOptions{}

	resp, err := vpcClient.ReleaseEipAddressWithOptions(releaseEipAddressReq, runtime)
	if err != nil {
		logError.Println("Fail to ReleaseEipAddress.", err)
	}
	logInfo.Printf("EipAddress Released: %s", resp.GoString())
	return resp
}

func fakeAllocateEipResponse() *vpc.AllocateEipAddressResponse {
	resp := &vpc.AllocateEipAddressResponse{}
	respBody := &vpc.AllocateEipAddressResponseBody{}
	respBody.SetAllocationId("eip-test-test")
	respBody.SetEipAddress("127.0.0.1")
	resp.SetBody(respBody)
	return resp
}
