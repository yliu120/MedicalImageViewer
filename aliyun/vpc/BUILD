load("@io_bazel_rules_go//go:def.bzl", "go_library")

package(default_visibility = ["//aliyun:friends"])

go_library(
    name = "utils",
    srcs = ["utils.go"],
    importpath = "github.com/yliu120/MedicalImageViewer/aliyun/vpc",
    deps = [
        "@com_github_alibabacloud_go_darabonba_openapi_v2//client",
        "@com_github_alibabacloud_go_tea_utils_v2//service",
        "@com_github_alibabacloud_go_vpc_20160428_v2//client",
    ],
)
