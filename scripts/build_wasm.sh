#!/usr/bin/env bash

set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
qt_version="${QT_VERSION:-6.11.1}"
emsdk_root="${EMSDK_ROOT:-${EMSDK:-${HOME}/.local/share/emsdk}}"
qt_wasm_path="${QT_WASM_PATH:-${QT_ROOT_DIR:-${HOME}/Qt/${qt_version}/wasm_singlethread}}"
qt_host_path="${QT_HOST_PATH:-}"
build_dir="${BUILD_DIR:-${project_dir}/build-wasm}"

if [[ "${build_dir}" != /* ]]; then
    build_dir="${project_dir}/${build_dir}"
fi

if [[ ! -f "${emsdk_root}/emsdk_env.sh" ]]; then
    echo "Emscripten environment not found: ${emsdk_root}/emsdk_env.sh" >&2
    exit 1
fi

if [[ -z "${qt_host_path}" ]]; then
    echo "QT_HOST_PATH must point to the matching desktop Qt installation." >&2
    exit 1
fi

qt_cmake="${qt_wasm_path}/bin/qt-cmake"
qt_toolchain="${qt_wasm_path}/lib/cmake/Qt6/qt.toolchain.cmake"
qt_host_config="${qt_host_path}/lib/cmake/Qt6/Qt6Config.cmake"

if [[ ! -f "${qt_cmake}" ]]; then
    echo "Qt for WebAssembly not found: ${qt_cmake}" >&2
    exit 1
fi

if [[ ! -f "${qt_toolchain}" ]]; then
    echo "Qt WebAssembly toolchain not found: ${qt_toolchain}" >&2
    exit 1
fi

if [[ ! -f "${qt_host_config}" ]]; then
    echo "Qt host tools not found: ${qt_host_path}" >&2
    exit 1
fi

# shellcheck disable=SC1090
source "${emsdk_root}/emsdk_env.sh" >/dev/null

cmake_args=(
    -S "${project_dir}"
    -B "${build_dir}"
    -G Ninja
    -DBUILD_PLAYGROUND=ON
    -DBUILD_TESTS=OFF
    -DCMAKE_BUILD_TYPE="${BUILD_TYPE:-MinSizeRel}"
    -DQT_HOST_PATH="${qt_host_path}"
)

if [[ -n "${QT_CHAINLOAD_TOOLCHAIN_FILE:-}" ]]; then
    cmake_args+=(
        "-DQT_CHAINLOAD_TOOLCHAIN_FILE=${QT_CHAINLOAD_TOOLCHAIN_FILE}"
    )
fi

sh "${qt_cmake}" "${cmake_args[@]}" "$@"
cmake --build "${build_dir}" --target QtToastifyPlayground --parallel

target_dir="${build_dir}/playground"
outputs=(
    QtToastifyPlayground.html
    QtToastifyPlayground.js
    QtToastifyPlayground.wasm
    qtloader.js
    qtlogo.svg
)

for output in "${outputs[@]}"; do
    output_path="${target_dir}/${output}"
    if [[ ! -s "${output_path}" ]]; then
        echo "Missing WebAssembly output: ${output_path}" >&2
        exit 1
    fi
done

wasm_output="${target_dir}/QtToastifyPlayground.wasm"
qml_plugins=(
    ToastifyPlugin
    Toastify_StylePlugin
    Merce_ThemePlugin
    Merce_FoundationPlugin
    Merce_StylePlugin
    Merce_ControlsPlugin
    Qt_labs_StyleKitPlugin
    QtQuickVectorImagePlugin
    QtQuickVectorImageHelpersPlugin
)

for qml_plugin in "${qml_plugins[@]}"; do
    if ! grep -aFq "${qml_plugin}" "${wasm_output}"; then
        echo "Missing static QML plugin in WebAssembly output: ${qml_plugin}" >&2
        exit 1
    fi
done

site_dir="${build_dir}/site"
cmake -E make_directory "${site_dir}"
cmake -E copy_if_different \
    "${target_dir}/QtToastifyPlayground.html" \
    "${site_dir}/index.html"

for output in QtToastifyPlayground.js QtToastifyPlayground.wasm qtloader.js qtlogo.svg; do
    cmake -E copy_if_different \
        "${target_dir}/${output}" \
        "${site_dir}/${output}"
done

echo "WebAssembly site built in ${site_dir}"
