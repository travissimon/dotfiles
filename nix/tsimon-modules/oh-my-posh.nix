{
  pkgs,
  config,
  ...
}: {

  programs = {

    oh-my-posh = {
      enable = true;
      enableBashIntegration = true;
      settings = builtins.fromJSON (''
{
  "palette": {
    "bg01": "#170B3B",
    "fg01": "#FAFAFA",
    "bg02": "#341948",
    "fg02": "#EFDCF9",
    "bg03": "#4c1f5e",
    "fg03": "#EFDCF9",
    "bg04": "#69307A",
    "fg04": "#EFDCF9",
    "bg06": "#4c1f5e",
    "fg06": "#7FD5EA"
   },
  "blocks": [
    {
      "alignment": "left",
      "segments": [
        {
          "background": "p:bg01",
          "foreground": "p:fg01",
          "properties": {
            "arch": "\uf303",
            "debian": "\uf306",
            "fedora": "\uf30a",
            "linux": "\uf17c",
            "macos": "\uf179",
            "nixos": "\uf313",
            "manjaro": "\uf312",
            "opensuse": "\uf314",
            "ubuntu": "\uf31b",
            "windows": "\uf17a"
          },
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "leading_powerline_symbol": "\ue0b6",
          "template": "{{.Icon}} {{ if .WSL }} (WSL){{ end }}",
          "type": "os"
        },
        {
          "background": "p:bg02",
          "foreground": "p:fg02",
          "properties": {
            "mapped_locations": {
              "~/work/regsoft/src": "\uf0e3"
            },
            "style": "full"
          },
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "template": " {{ .Path }} ",
          "type": "path"
        },
        {
          "background": "p:bg03",
          "foreground": "p:fg03",
          "properties": {
            "branch_template": "{{ trunc 25 .Branch }}",
            "fetch_stash_count": true,
            "fetch_status": true,
            "fetch_upstream_icon": true
          },
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "template": " {{ .UpstreamIcon }}{{ .HEAD }}{{if .BranchStatus }} {{ .BranchStatus }}{{ end }}{{ if .Working.Changed }} \uf044 {{ .Working.String }}{{ end }}{{ if and (.Working.Changed) (.Staging.Changed) }} |{{ end }}{{ if .Staging.Changed }} \uf046 {{ .Staging.String }}{{ end }}{{ if gt .StashCount 0 }} \ueb4b {{ .StashCount }}{{ end }} ",
          "type": "git"
        },
        {
          "background": "p:bg04",
          "foreground": "p:fg04",
          "properties": {
            "always_enabled": true
          },
          "style": "powerline",
          "powerline_symbol": "\ue0b0",
          "template": " {{ .FormattedMs }} ",
          "type": "executiontime"
        }
      ],
      "type": "prompt"
    },
    {
      "alignment": "right",
      "segments": [
        {
          "background": "p:bg06",
          "foreground": "p:fg06",
          "leading_diamond": " \ue0b6",
          "properties": {
            "fetch_version": false
          },
          "style": "diamond",
          "template": "\ue235{{ if .Error }}{{ .Error }}{{ else }}{{ if .Venv }}{{ .Venv }} {{ end }}{{ .Full }}{{ end }}",
          "trailing_diamond": "\ue0b4",
          "type": "python"
        },
        {
          "background": "p:bg06",
          "foreground": "p:fg06",
          "leading_diamond": " \ue0b6",
          "properties": {
            "fetch_version": false
          },
          "style": "diamond",
          "template": "\ue626{{ if .Error }}{{ .Error }}{{ else }}{{ .Full }}{{ end }}",
          "trailing_diamond": "\ue0b4",
          "type": "go"
        },
        {
          "background": "p:bg06",
          "foreground": "p:fg06",
          "leading_diamond": " \ue0b6",
          "properties": {
            "fetch_version": false
          },
          "style": "diamond",
          "template": "\ue718{{ if .PackageManagerIcon }}{{ .PackageManagerIcon }} {{ end }}{{ .Full }}",
          "trailing_diamond": "\ue0b4",
          "type": "node"
        }
      ],
      "type": "rprompt"
    }
  ],
  "console_title_template": "{{ .Folder }}",
  "final_space": true,
  "version": 3
}
      '');
    };


  };

}
