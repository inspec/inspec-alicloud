+++
title = "{{ .Name | humanize | title }} resource"
draft = false
gh_repo = "inspec"
platform = "alicloud"

[menu]
  [menu.inspec]
    title = "{{ .Name | humanize | title }}"
    identifier = "inspec/resources/alicloud/{{ .Name | humanize | title }}"
    parent = "inspec/resources/alicloud"
+++


{{% Run `hugo new -k resource resources/RESOURCE_NAME.md` to generate a new resource page. %}}

## Syntax

## Parameters

## Properties

## Examples

## Matchers

For a full list of available matchers, please visit our [Universal Matchers page](https://docs.chef.io/inspec/matchers/).
