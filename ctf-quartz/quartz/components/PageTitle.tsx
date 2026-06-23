import { pathToRoot } from "../util/path"
import { QuartzComponent, QuartzComponentConstructor, QuartzComponentProps } from "./types"
import { classNames } from "../util/lang"
import { i18n } from "../i18n"

const PageTitle: QuartzComponent = ({ fileData, cfg, displayClass }: QuartzComponentProps) => {
  const title = cfg?.pageTitle ?? i18n(cfg.locale).propertyDefaults.title
  const baseDir = pathToRoot(fileData.slug!)
  return (
    <div class={classNames(displayClass, "page-title")}>
      <a class="page-title__parent" href="/" data-router-ignore="true">
        Back to CameronCandau.com
      </a>
      <h2 class="page-title__home">
        <a href={baseDir}>{title}</a>
      </h2>
    </div>
  )
}

PageTitle.css = `
.page-title {
  margin: 0;
  font-family: var(--titleFont);
}

.page-title__parent {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  margin-bottom: 0.45rem;
  font-size: 0.82rem;
  font-weight: 600;
  letter-spacing: 0.04em;
  text-transform: uppercase;
  opacity: 0.8;
}

.page-title__parent::before {
  content: "←";
  font-size: 0.9em;
}

.page-title__home {
  font-size: 1.75rem;
  margin: 0;
}
`

export default (() => PageTitle) satisfies QuartzComponentConstructor
