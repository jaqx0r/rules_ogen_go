# Bazel rules to generate a Go OpenAPI service handler and client from an OpenAPI specification.

This is a bazel module that wraps the https://github.com/ogen-go/ogen code generator.

Add to `MODULE.bazel`:

``` bazel
bazel_dep(name = "rules_ogen_go", version = "0.0.0")
git_override(
    module_name ="rules_ogen_go",
    commit = "000",
    remote ="https://github.com/jaqx0r/rules_ogen_go.git",
)
```


Add to the `BUILD.bazel`:

``` bazel
load("@rules_ogen_go//:ogen_go")

ogen_go(
    name ="ogen",
    src = ":api.yaml",
    package ="api",
)

go_library(
    name = "apiservice",
    srcs = [
        "apiservice.go"
    ],
    embed = [
        ":ogen", # keep
    ],
)
```
