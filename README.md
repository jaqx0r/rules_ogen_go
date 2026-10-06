# Bazel rules to generate a Go OpenAPI service handler and client from an OpenAPI specification.

This is a [Bazel](https://bazel.build) module that wraps the https://github.com/ogen-go/ogen code generator.

Add to `MODULE.bazel`:

``` starlark
bazel_dep(name = "rules_ogen_go", version = "0.0.0")
git_override(
    module_name = "rules_ogen_go",
    commit = "353e8604745de04cdf6808356e5f0cb45c810206",
    remote ="https://github.com/jaqx0r/rules_ogen_go.git",
)
```


Add to the `BUILD.bazel`:

``` starlark
load("@rules_ogen_go//:ogen_go")

ogen_go(
    name = "ogen",
    src = ":api.yaml",
    package = "api",
)

go_library(
    name = "apiservice",
    srcs = [
        "apiservice.go",
    ],
    embed = [
        ":ogen", # keep
    ],
)
```
