
def _jar_jar_impl(ctx):
  ctx.action(
    inputs=[ctx.file.rules, ctx.file.input_jar],
    outputs=[ctx.outputs.jar],
    executable=ctx.executable.jarjar_runner,
    progress_message="jarjar %s" % ctx.label,
    arguments=["process", ctx.file.rules.path, ctx.file.input_jar.path, ctx.outputs.jar.path])

  return [
    JavaInfo(
        output_jar = ctx.outputs.jar,
        compile_jar = ctx.outputs.jar
    ),
    DefaultInfo(files = depset([ctx.outputs.jar]))
  ]

jar_jar = rule(
    implementation = _jar_jar_impl,
    attrs = {
        "input_jar": attr.label(allow_files=True, single_file=True),
        "rules": attr.label(allow_files=True, single_file=True),
        "jarjar_runner": attr.label(executable=True, cfg="host", default=Label("@com_github_johnynek_bazel_jar_jar//:jarjar_runner")),
    },
    outputs = {
      "jar": "%{name}.jar"
    },
    provides = [JavaInfo])

def _mvn_name(coord):
  nocolon = "_".join(coord.split(":"))
  nodot = "_".join(nocolon.split("."))
  nodash = "_".join(nodot.split("-"))
  return nodash

def _mvn_jar(coord, sha, bname, serv):
  nm = _mvn_name(coord)
  native.maven_jar(
    name = nm,
    artifact = coord,
    sha1 = sha,
    server = serv
  )
  native.bind(name=("com_github_johnynek_bazel_jar_jar/%s" % bname), actual = "@%s//jar" % nm)

def jar_jar_repositories(server=None):
  _mvn_jar(
    "org.pantsbuild:jarjar:1.7.2",
    "8e258f158b4572d40598d7f4793cfbfe84a7cc70",
    "jarjar",
    server)
  _mvn_jar(
    "org.ow2.asm:asm:7.0",
    "d74d4ba0dee443f68fb2dcb7fcdb945a2cd89912",
    "asm",
    server)
  _mvn_jar(
    "org.ow2.asm:asm-commons:7.0",
    "478006d07b7c561ae3a92ddc1829bca81ae0cdd1",
    "asm_commons",
    server)
