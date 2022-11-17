load("@io_bazel_rules_jsonnet//jsonnet:jsonnet.bzl", "jsonnet_to_json")

package(default_visibility = ["//visibility:private"])

jsonnet_to_json(
    name = "deploy_conf",
    src = "deploy.jsonnet",
    outs = [
        "deploy.json",
    ],
    deps = [
        "//aliyun/base:client",
        "//aliyun/eci/md_notebook:template",
    ],
)

genrule(
    name = "up_dry_run",
    srcs = [
        "//aliyun/eci:deploy",
    ],
    outs = ["deploy_dry_run"],
    cmd = "$(location //aliyun/eci:deploy) --conf=$(location deploy.json) --dry_run && echo done > $@",
    tools = [
        ":deploy.json",
    ],
)

genrule(
    name = "up",
    srcs = [
        "//aliyun/eci:deploy",
    ],
    outs = ["deploy"],
    cmd = "$(location //aliyun/eci:deploy) --conf=$(location deploy.json) && echo done > $@",
    tools = [
        ":deploy.json",
    ],
)
