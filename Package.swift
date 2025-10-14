// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "JQ",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "JQ",
            targets: ["JQ"]
        ),
    ],
    dependencies: [
        // DocC plugin for generating documentation from DocC comments
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "Cjq",
            dependencies: [],
            exclude: [
                "jq/src/main.c",
                "jq/src/jq_test.c",
                "jq/src/inject_errors.c",
                "jq/modules/oniguruma/sample",
                "jq/modules/oniguruma/test",
                "jq/modules/oniguruma/doc",
            ],
            sources: [
                "jq/src/builtin.c",
                "jq/src/bytecode.c",
                "jq/src/compile.c",
                "jq/src/execute.c",
                "jq/src/jv.c",
                "jq/src/jv_alloc.c",
                "jq/src/jv_aux.c",
                "jq/src/jv_dtoa.c",
                "jq/src/jv_dtoa_tsd.c",
                "jq/src/jv_file.c",
                "jq/src/jv_parse.c",
                "jq/src/jv_print.c",
                "jq/src/jv_unicode.c",
                "jq/src/lexer.c",
                "jq/src/linker.c",
                "jq/src/locfile.c",
                "jq/src/parser.c",
                "jq/src/util.c",
                // Oniguruma sources (use vendor path for portability)
                "jq/modules/oniguruma/src/regparse.c",
                "jq/modules/oniguruma/src/regext.c",
                "jq/modules/oniguruma/src/regcomp.c",
                "jq/modules/oniguruma/src/reggnu.c",
                "jq/modules/oniguruma/src/regenc.c",
                "jq/modules/oniguruma/src/regerror.c",
                "jq/modules/oniguruma/src/regexec.c",
                "jq/modules/oniguruma/src/regsyntax.c",
                "jq/modules/oniguruma/src/regtrav.c",
                "jq/modules/oniguruma/src/regversion.c",
                "jq/modules/oniguruma/src/st.c",
                "jq/modules/oniguruma/src/onig_init.c",
                "jq/modules/oniguruma/src/unicode.c",
                "jq/modules/oniguruma/src/unicode_fold1_key.c",
                "jq/modules/oniguruma/src/unicode_fold2_key.c",
                "jq/modules/oniguruma/src/unicode_fold3_key.c",
                "jq/modules/oniguruma/src/unicode_unfold_key.c",
                "jq/modules/oniguruma/src/ascii.c",
                "jq/modules/oniguruma/src/utf8.c",
                "jq/modules/oniguruma/src/utf16_be.c",
                "jq/modules/oniguruma/src/utf16_le.c",
                "jq/modules/oniguruma/src/utf32_be.c",
                "jq/modules/oniguruma/src/utf32_le.c",
                "jq/modules/oniguruma/src/euc_jp.c",
                "jq/modules/oniguruma/src/euc_jp_prop.c",
                "jq/modules/oniguruma/src/sjis.c",
                "jq/modules/oniguruma/src/sjis_prop.c",
                "jq/modules/oniguruma/src/iso8859_1.c",
                "jq/modules/oniguruma/src/iso8859_2.c",
                "jq/modules/oniguruma/src/iso8859_3.c",
                "jq/modules/oniguruma/src/iso8859_4.c",
                "jq/modules/oniguruma/src/iso8859_5.c",
                "jq/modules/oniguruma/src/iso8859_6.c",
                "jq/modules/oniguruma/src/iso8859_7.c",
                "jq/modules/oniguruma/src/iso8859_8.c",
                "jq/modules/oniguruma/src/iso8859_9.c",
                "jq/modules/oniguruma/src/iso8859_10.c",
                "jq/modules/oniguruma/src/iso8859_11.c",
                "jq/modules/oniguruma/src/iso8859_13.c",
                "jq/modules/oniguruma/src/iso8859_14.c",
                "jq/modules/oniguruma/src/iso8859_15.c",
                "jq/modules/oniguruma/src/iso8859_16.c",
                "jq/modules/oniguruma/src/euc_tw.c",
                "jq/modules/oniguruma/src/euc_kr.c",
                "jq/modules/oniguruma/src/big5.c",
                "jq/modules/oniguruma/src/gb18030.c",
                "jq/modules/oniguruma/src/koi8_r.c",
                "jq/modules/oniguruma/src/cp1251.c",
            ],
            publicHeadersPath: "include",
            cSettings: [
                // Platform feature macros
                .define("_GNU_SOURCE", .when(platforms: [.linux])),
                .define("HAVE_MEMMEM", .when(platforms: [.linux, .macOS])),
                .define("HAVE_ISATTY", .when(platforms: [.linux, .macOS])),
                .define("HAVE_STRPTIME"),
                .define("HAVE_STRFTIME"),
                .define("HAVE_TIMEGM", .when(platforms: [.linux, .macOS])),
                .define("HAVE_GMTIME_R", .when(platforms: [.linux, .macOS])),
                .define("HAVE_LOCALTIME_R", .when(platforms: [.linux, .macOS])),
                .define("IEEE_8087"),  // Little-endian IEEE floating point (x86, ARM)
                // Enable Oniguruma-backed regex support in jq
                .define("HAVE_LIBONIG", to: "1"),
                // Prefer jq paths before our wrapper include dir
                .headerSearchPath("jq"),
                .headerSearchPath("jq/src"),
                .headerSearchPath("jq/modules/oniguruma/src"),
                .headerSearchPath("include"),
                // Avoid using unsafe compiler flags so this package can be
                // consumed as a dependency without requiring Xcode/SPM opt‑ins.
            ],
            linkerSettings: [
                .linkedLibrary("m", .when(platforms: [.linux]))
            ]
        ),
        .target(
            name: "JQ",
            dependencies: ["Cjq"],
            swiftSettings: []
        ),
        .testTarget(
            name: "JQTests",
            dependencies: ["JQ"]
        ),
    ]
)
