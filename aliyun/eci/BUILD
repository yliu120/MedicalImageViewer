load("@io_bazel_rules_go//go:def.bzl", "go_binary", "go_library")
load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_library")

package(default_visibility = ["//aliyun:friends"])

go_binary(
    name = "deploy",
    embed = [":eci_lib"],
    visibility = ["//visibility:public"],
)

go_library(
    name = "eci_lib",
    srcs = ["deploy.go"],
    importpath = "github.com/yliu120/MedicalImageViewer/aliyun/eci",
    visibility = ["//visibility:private"],
    deps = [
        "//aliyun/vpc:utils",
        "@com_github_alibabacloud_go_darabonba_openapi_v2//client",
        "@com_github_alibabacloud_go_eci_20180808_v3//client",
        "@com_github_alibabacloud_go_tea_utils_v2//service",
    ],
)

jsonnet_library(
    name = "template",
    srcs = ["template.libsonnet"],
)
