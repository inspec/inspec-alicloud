+++
title = "{{ .Name }} resource"
draft = false
gh_repo = "inspec"
platform = "alicloud"

[menu]
  [menu.inspec]
    title = "{{ .Name | humanize | title }}"
    identifier = "inspec/resources/alicloud/{{ .Name | humanize | title }}"
    parent = "inspec/resources/alicloud"
+++
{{/* Run `hugo new -k resource inspec/resources/RESOURCE_NAME.md` to generate a new resource page. */}}

Use the `{{ .Name }}` Chef InSpec audit resource to test...

## Syntax

```ruby
describe {{ .Name }} do

end
```

## Parameters

`PARAMETER`
: PARAMETER DESCRIPTION

`PARAMETER`
: PARAMETER DESCRIPTION

## Properties

`PROPERTY`
: PROPERTY DESCRIPTION

`PROPERTY`
: PROPERTY DESCRIPTION

## Examples

**EXAMPLE DESCRIPTION**

```ruby
describe {{ .Name }} do

end
```

**EXAMPLE DESCRIPTION**

```ruby
describe {{ .Name }} do

end
```

## Matchers

{{% inspec_matchers_link %}}

### AliCloud Permissions

{{% alibaba_access_management_docs %}}
