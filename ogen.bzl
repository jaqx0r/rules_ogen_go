"""Generate OpenAPI client and server for Go."""

load("@rules_go//go:def.bzl", "GoArchive", "go_context", "new_go_info")
load("@rules_go//go/private:context.bzl", "CGO_ATTRS", "CGO_FRAGMENTS", "CGO_TOOLCHAINS")

_OGEN_TOOL = Label("@com_github_ogen_go_ogen//cmd/ogen")

OGEN_OUTS = [
    # keep-sorted
    "oas_cfg_gen.go",
    "oas_client_gen.go",
    "oas_handlers_gen.go",
    "oas_json_gen.go",
    "oas_labeler_gen.go",
    "oas_middleware_gen.go",
    "oas_operations_gen.go",
    "oas_parameters_gen.go",
    "oas_request_decoders_gen.go",
    "oas_request_encoders_gen.go",
    "oas_response_decoders_gen.go",
    "oas_response_encoders_gen.go",
    "oas_router_gen.go",
    "oas_schemas_gen.go",
    "oas_server_gen.go",
    "oas_servers_gen.go",
    "oas_security_gen.go",
    "oas_unimplemented_gen.go",
    "oas_validators_gen.go",
    # end keep-sorted
]

OGEN_DEPS = [
    # keep-sorted
    "@com_github_go_faster_errors//:go_default_library",
    "@com_github_go_faster_jx//:go_default_library",
    "@com_github_ogen_go_ogen//conv:go_default_library",
    "@com_github_ogen_go_ogen//http:go_default_library",
    "@com_github_ogen_go_ogen//json:go_default_library",
    "@com_github_ogen_go_ogen//middleware:go_default_library",
    "@com_github_ogen_go_ogen//ogenerrors:go_default_library",
    "@com_github_ogen_go_ogen//ogenregex:go_default_library",
    "@com_github_ogen_go_ogen//otelogen:go_default_library",
    "@com_github_ogen_go_ogen//uri:go_default_library",
    "@com_github_ogen_go_ogen//validate:go_default_library",
    "@io_opentelemetry_go_otel//:go_default_library",
    "@io_opentelemetry_go_otel//attribute:go_default_library",
    "@io_opentelemetry_go_otel//codes:go_default_library",
    "@io_opentelemetry_go_otel//semconv/v1.39.0:go_default_library",
    "@io_opentelemetry_go_otel_metric//",
    "@io_opentelemetry_go_ote_trace//:go_default_library",
    # end keep-sorted
]

_MODE_CONFIG = {
    "client": """\
generator:
  features:
    disable:
      - 'paths/server'
""",
    "server": """\
generator:
  features:
    disable:
      - 'paths/client'
""",
}

def _ogen_go_impl(ctx):
    """Implementation of a buildf rule to execute `ogen`, to generate Go OpenAPI handler code."""

    # `ogen` requires the Go toolchain binary in the sandbox.
    go_ctx = go_context(ctx)

    outputs = [go_ctx.declare_file(go_ctx, file) for file in OGEN_OUTS]

    mode = ctx.attr.mode
    config_flags = ""
    extra_inputs = []

    if mode in _MODE_CONFIG:
        config_file = ctx.actions.declare_file(ctx.label.name + ".ogen.yaml")
        ctx.actions.write(
            output = config_file,
            content = _MODE_CONFIG[mode],
        )
        config_flags = "-config " + config_file.path
        extra_inputs = [config_file]

    wrapper = ctx.actions.declare_file(ctx.label.name + "_ogen_wrapper.sh")
    ctx.actions.expand_template(
        template = ctx.file._ogen_wrapper_template,
        output = wrapper,
        substitutions = {
            "{{goroot}}": go_ctx.sdk.root_file.dirname,
            "{{ogen}}": ctx.executable._ogen_tool.path,
            "{{target}}": outputs[0].dirname,
            "{{package}}": ctx.attr.package or ctx.label.name,
            "{{spec}}": ctx.file.src.path,
            "{{config_flags}}": config_flags,
            "{{expected_outputs}}": " ".join(OGEN_OUTS),
        },
        is_executable = True,
    )

    inputs = depset(direct = [ctx.file.src, go_ctx.sdk.go] + extra_inputs)

    go_ctx.actions.run(
        mnemonic = "OGen",
        executable = wrapper,
        inputs = inputs,
        outputs = outputs,
        tools = [ctx.executable._ogen_tool],
    )

    attr = struct(
        deps = ctx.attr._gen_deps,
    )

    go_info = new_go_info(
        go = go_ctx,
        attr = attr,
        generated_srcs = outputs,
    )

    go_archive = go_ctx.archive(
        go = go_ctx,
        source = go_info,
    )

    return [
        go_info,
        go_archive,
    ]

ogen_go = rules(
    implementation = _ogen_go_impl,
    doc = """Generate a Go API service handler from an OpenAPI specification.""",
    attrs = {
        "src": attr.label(
            allow_single_file = True,
            doc = "The source OpenAPI specification.",
            mandatory = True,
        ),
        "out_dir": attr.string(
            doc = "The output target directory to write the API handler code to. Defaults to `.`",
            default = ".",
        ),
        "package": attr.string(doc = "The package name to give to the generated code.", mandatory = True),
        "mode": attr.string(doc = "Generation mode: `all` generates both client and server (default), `client` generates client only, `server` generates server only.", default = "all", values = ["all", "client", "server"]),
        "_ogen_tool": attr.label(
            default = _OGEN_TOOL,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "_ogen_wrapper_template": attr.label(default = "//:ogen_wrapper_template.sh", allow_single_file = True),
        "_go_context_data": attr.label(default = "@rules_go//:go_context_data"),
        "_gen_deps": attr.label_list(
            providers = [GoArchive],
            default = OGEN_DEPS,
        ),
    } | CGO_ATTRS,
    toolchains = ["@rules_go//go:toolchain"] + CGO_TOOLCHAINS,
    fragments = CGO_FRAGMENTS,
)
