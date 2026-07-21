#!/usr/bin/env bash
set -euo pipefail

VERSION="0.1.0"
COMPONENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES_DIR="${COMPONENT_DIR}/templates"
CANTON_BLUE='\033[0;34m'
CANTON_GREEN='\033[0;32m'
CANTON_YELLOW='\033[0;33m'
CANTON_RED='\033[0;31m'
RESET='\033[0m'

info()    { echo -e "${CANTON_BLUE}[canton-scaffold]${RESET} $*"; }
success() { echo -e "${CANTON_GREEN}[canton-scaffold]${RESET} $*"; }
warn()    { echo -e "${CANTON_YELLOW}[canton-scaffold]${RESET} $*"; }
error()   { echo -e "${CANTON_RED}[canton-scaffold]${RESET} $*" >&2; exit 1; }

usage() {
  cat <<EOF

${CANTON_BLUE}canton-scaffold${RESET} v${VERSION} Canton Project scaffolder

USAGE:
  dpm canton-scaffold <command> [args]

COMMANDS:
  list                         Show all available templates
  new <template> <project>     Scaffold a new project from a template
  info <template>              Show details about a template
  --version                    Print component version
  --help                       Show this help

TEMPLATES:
  canton-dapp        
  canton-token-app

EXAMPLES:
  dpm canton-scaffold list
  dpm canton-scaffold new canton-dapp my-first-app
  dpm canton-scaffold new canton-token-app my-token --sdk-version 3.5.0
  dpm canton-scaffold info canton-dapp
EOF
}

cmd_list() {
  echo ""
  echo -e "${CANTON_BLUE}Available canton-scaffold templates:${RESET}"
  echo ""
  printf "  %-28s %s\n" "canton-dapp" "Full-stack Canton dApp"
  printf "  %-28s %s\n" "canton-token-app" "CIP-0056 token standard starter"
  echo ""
  echo -e "Run ${CANTON_BLUE}dpm canton-scaffold info <template>${RESET} for details."
  echo ""
}

cmd_info() {
  local template="${1:-}"
  [[ -z "$template" ]] && error "Usage: dpm canton-scaffold info <template>"

  case "$template" in
    canton-dapp)
      cat <<EOF

${CANTON_BLUE}canton-dapp${RESET}

Generates:
  daml/                   Daml smart contracts (template + choices)
  daml.yaml               Package config (sdk-version, dependencies)

Requires:
  DPM 1.0.14+ / SDK 3.5+

EOF
      ;;
    canton-token-app)
      cat <<EOF

${CANTON_BLUE}canton-token-app${RESET}
CIP-0056 token standard application starter.

Generates:
  daml/                   Token contract (CIP-0056 interface implementation)
  daml.yaml               Includes splice-amulet data-dependency
EOF
      ;;
    *)
      error "Unknown template: '$template'. Run 'dpm canton-scaffold list' to see available templates."
      ;;
  esac
}

cmd_new() {
  local template="${1:-}"
  local project_name="${2:-}"

  [[ -z "$template" ]]      && error "Usage: dpm canton-scaffold new <template> <project-name>"
  [[ -z "$project_name" ]]  && error "Usage: dpm canton-scaffold new <template> <project-name>"

  local sdk_version="3.5.0"
  shift 2
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --sdk-version) sdk_version="$2"; shift 2 ;;
      *) warn "Unknown option: $1"; shift ;;
    esac
  done

  local target_dir="${project_name}"
  local template_dir="${TEMPLATES_DIR}/${template}"

  [[ ! -d "$template_dir" ]] && error "Template '${template}' not found. Run 'dpm canton-scaffold list'."
  [[ -d "$target_dir" ]]     && error "Directory '${project_name}' already exists."

  info "Scaffolding '${project_name}' from template '${template}'..."
  info "SDK version: ${sdk_version}"


  cp -r "$template_dir" "$target_dir"
  find "$target_dir" -type f | while read -r file; do
    sed -i.bak \
      -e "s/__PROJECT_NAME__/${project_name}/g" \
      -e "s/__SDK_VERSION__/${sdk_version}/g" \
      "$file" && rm -f "${file}.bak"
  done

  find "$target_dir" -depth -name "*__PROJECT_NAME__*" | while read -r path; do
    mv "$path" "$(echo "$path" | sed "s/__PROJECT_NAME__/${project_name}/g")"
  done

  success "Project '${project_name}' created at ${target_dir}"
  echo ""
  echo "  Next steps:"
  echo ""
  case "$template" in
    canton-dapp)
      echo "    cd ${project_name}"
      echo "    dpm install package        # install SDK components"
      echo "    dpm build                  # compile Daml contracts"
      ;;
    canton-token-app)
      echo "    cd ${project_name}"
      echo "    dpm install package"
      echo "    dpm build"
      ;;
  esac
  echo ""
}

main() {
  local cmd="${1:-}"

  case "$cmd" in
    list)                  cmd_list ;;
    info)                  shift; cmd_info "$@" ;;
    new)                   shift; cmd_new "$@" ;;
    --version|-v)          echo "canton-scaffold ${VERSION}" ;;
    --help|-h|"")          usage ;;
    *)
      if [[ -d "${TEMPLATES_DIR}/${cmd}" ]]; then
        shift; cmd_new "$cmd" "$@"
      else
        error "Unknown command: '${cmd}'. Run 'dpm canton-scaffold --help'."
      fi
      ;;
  esac
}
main "$@"