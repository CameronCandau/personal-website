import { QuartzConfig } from "./quartz/cfg"
import * as Plugin from "./quartz/plugins"

/**
 * Quartz 4 Configuration
 *
 * See https://quartz.jzhao.xyz/configuration for more information.
 */
const config: QuartzConfig = {
  configuration: {
    pageTitle: "/CTF",
    pageTitleSuffix: " - Cameron Candau",
    enableSPA: true,
    enablePopovers: true,
    /*
    analytics: {
      provider: "plausible",
    },
    */
    locale: "en-US",
    baseUrl: "cameroncandau.com/ctf",
    ignorePatterns: ["private", "templates", ".obsidian"],
    defaultDateType: "modified",
    theme: {
      fontOrigin: "googleFonts",
      cdnCaching: true,
      typography: {
        header: "Source Sans 3",
        body: "Source Sans 3",
        code: "IBM Plex Mono",
      },
      colors: {
        lightMode: {
          light: "#f5f7ff",
          lightgray: "#ccd0da",
          gray: "#8c8fa1",
          darkgray: "#4c4f69",
          dark: "#1e2030",
          secondary: "#40a02b",
          tertiary: "#179299",
          highlight: "rgba(64, 160, 43, 0.12)",
          textHighlight: "#a6d18966",
        },
        darkMode: {
          light: "#1e1e2e",
          lightgray: "#313244",
          gray: "#7f849c",
          darkgray: "#cdd6f4",
          dark: "#f5f7ff",
          secondary: "#a6e3a1",
          tertiary: "#94e2d5",
          highlight: "rgba(166, 227, 161, 0.12)",
          textHighlight: "#a6e3a144",
        }
      }
    },
  },
  plugins: {
    transformers: [
      Plugin.FrontMatter(),
      Plugin.CreatedModifiedDate({
        priority: ["frontmatter"],
      }),
      Plugin.SyntaxHighlighting({
        theme: {
          light: "github-light",
          dark: "github-dark",
        },
        keepBackground: false,
      }),
      Plugin.ObsidianFlavoredMarkdown({ enableInHtmlEmbed: false }),
      Plugin.GitHubFlavoredMarkdown(),
      Plugin.TableOfContents(),
      Plugin.CrawlLinks({ markdownLinkResolution: "shortest" }),
      Plugin.Description(),
      Plugin.Latex({ renderEngine: "katex" }),
    ],
    filters: [Plugin.RemoveDrafts()],
    emitters: [
      Plugin.AliasRedirects(),
      Plugin.ComponentResources(),
      Plugin.ContentPage(),
      Plugin.FolderPage(),
      Plugin.TagPage(),
      Plugin.ContentIndex({
        enableSiteMap: true,
        enableRSS: true,
      }),
      Plugin.Assets(),
      Plugin.Static(),
      Plugin.NotFoundPage(),
    ],
  },
}

export default config
