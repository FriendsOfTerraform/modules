# EventBridge Event Bus Module

This module will build and configure an [EventBridge](https://aws.amazon.com/eventbridge/) event bus and rules.

**This repository is a READ-ONLY sub-tree split**. See https://github.com/FriendsOfTerraform/modules to create issues or submit pull requests.

## Table of Contents

- [Example Usage](#example-usage)
  - [Basic Usage](#basic-usage)
- [Inputs](#inputs)
  - [Required](#required)
  - [Optional](#optional)
- [Outputs](#outputs)
- [Objects](#objects)

## Example Usage

### Basic Usage

```terraform
module "basic_usage" {
  source = "github.com/FriendsOfTerraform/aws-eventbridge-bus.git?ref=v1.0.0"

  name = "demo-bus"

  # manages multiple rules
  rules = {
    # the key of the map is the rule's name
    test-lambda = {
      event_pattern = jsonencode({
        source      = ["aws.workspaces"]
        detail-type = ["WorkSpaces Access"]
      })

      targets = [
        {
          arn          = "arn:aws:lambda:us-east-1:111122223333:function:psin-test:1"
          iam_role_arn = "arn:aws:iam::111122223333:role/test-event-bus"
        }
      ]
    }

    test-http = {
      event_pattern = jsonencode({
        source      = ["aws.workspaces"]
        detail-type = ["WorkSpaces Access"]
      })

      targets = [
        {
          arn          = "arn:aws:events:us-east-1:111122223333:api-destination/demo-api/abcdef0-1111-2222-87fd-868af648a706"
          iam_role_arn = "arn:aws:iam::111122223333:role/test-event-bus"
        }
      ]
    }
  }
}
```

<!-- TFDOCS_EXTRAS_START -->






## Inputs

### Required



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the event bus

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#rules">Rules</a>))</code></td>
    <td width="100%">rules</td>
    <td></td>
</tr>
<tr><td colspan="3">

Manage multiple rules for the bus.

    

    

    
**Examples:**
- [Basic Usage](#basic-usage)

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>


### Optional



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the event bus

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags_all</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for all resources deployed with this module

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The description of the event bus

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">kms_key_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The AWS KMS customer managed key for EventBridge to use for encryption. If not specified, the AWS default key will be used.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">policy</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify the JSON document for the event bus' resource-based policy

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Outputs



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Sensitive</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">event_bus_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

ARN of the event bus

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">event_bus_id</td>
    <td></td>
</tr>
<tr><td colspan="3">

Name of the event bus

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>

## Objects



#### CapacityProviderStrategy

The capacity provider strategy to use for the task. Mutually exclusive to `launch_type`

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">weight</td>
    <td></td>
</tr>
<tr><td colspan="3">

The weight value designates the relative percentage of the total number of tasks launched that should use the specified capacity provider. The weight value is taken into consideration after the base value, if defined, is satisfied.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">base</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The base value designates how many tasks, at a minimum, to run on the specified capacity provider. Only one capacity provider in a capacity provider strategy can have a base defined.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### ConfigureTargetInput

Customize the text from an event before EventBridge passes the event to the target of a rule. Can only define only one of the following: `constant`, `input_transformer`. If this is not specified, the original event will be sent to the target

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">constant</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The JSON document to be sent to the target instead of the original event

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#inputtransformer">InputTransformer</a>)</code></td>
    <td width="100%">input_transformer</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specify how to change some of the event text before passing it to the target. One or more JSON paths are extracted from the event text and used in a template that you provide. Refer to [this documentation][eventbridge-input-transformer] for more information

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### EcsTargetConfig

Configuration options for ECS target

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">task_definition_arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The ARN of the task definition to use to create new ECS task

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#networkconfig">NetworkConfig</a>)</code></td>
    <td width="100%">network_config</td>
    <td></td>
</tr>
<tr><td colspan="3">

Configures networking options for the ECS task

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Additional tags for the ECS task

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">count</td>
    <td><code>1</code></td>
</tr>
<tr><td colspan="3">

The number of tasks to be created

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_execute_command</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Whether or not to enable the execute command functionality for the containers in this task. If true, this enables execute command functionality on all containers in the task.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">enable_managed_tags</td>
    <td><code>true</code></td>
</tr>
<tr><td colspan="3">

Specifies whether to enable Amazon ECS managed tags for the task.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">launch_type</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Specifies the launch type on which your task is running. Mutually exclusive to `capacity_provider_strategy`

    
**Allowed Values:**
- `EC2`
- `EXTERNAL`
- `FARGATE`

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">platform_version</td>
    <td><code>"LATEST"</code></td>
</tr>
<tr><td colspan="3">

Specifies the platform version for the task. This is used only if `launch_type = "FARGATE"`. For more information about valid platform versions, see [AWS Fargate Platform Versions][fargate-platform-version].

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">propagate_tags_from_task_definition</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Specifies whether to propagate the tags from the task definition to the task.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(object(<a href="#capacityproviderstrategy">CapacityProviderStrategy</a>))</code></td>
    <td width="100%">capacity_provider_strategy</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

The capacity provider strategy to use for the task. Mutually exclusive to `launch_type`

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### HttpTargetConfig

Configuration options for HTTP and api gateway target

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">header_parameters</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A map of HTTP headers to add to the request.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">query_string_parameters</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

A map of query string parameters that are appended to the invoked endpoint.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### InputTransformer

Specify how to change some of the event text before passing it to the target. One or more JSON paths are extracted from the event text and used in a template that you provide. Refer to [this documentation][eventbridge-input-transformer] for more information

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>map(string)</code></td>
    <td width="100%">input_paths</td>
    <td></td>
</tr>
<tr><td colspan="3">

Key-value pairs that is used to define variables. You use JSON path to reference items in your event and store those values in variables. For instance, you could create an Input Path to reference values in the event.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">template</td>
    <td></td>
</tr>
<tr><td colspan="3">

The Input Template is a template for the information you want to pass to your target. You can create a template that passes either a string or JSON to the target.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### NetworkConfig

Configures networking options for the ECS task

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>list(string)</code></td>
    <td width="100%">subnet_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of subnets the ECS task may be created on

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>list(string)</code></td>
    <td width="100%">security_group_ids</td>
    <td></td>
</tr>
<tr><td colspan="3">

A list of security groups associated with the task

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">auto_assign_public_ip</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Assign a public IP address to the ENI (Fargate launch type only).

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### RedshiftTargetConfig

Configuration options for Redshift target

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">database_name</td>
    <td></td>
</tr>
<tr><td colspan="3">

The name of the database

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">database_user</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The database user name

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">secret_manager_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ARN of the secret that enables access to the database.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">sql_statement</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The SQL statement text to run.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>bool</code></td>
    <td width="100%">with_event</td>
    <td><code>false</code></td>
</tr>
<tr><td colspan="3">

Indicates whether to send an event back to EventBridge after the SQL statement runs.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### RetryPolicy

Configures retry policy and dead-letter queue

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>number</code></td>
    <td width="100%">maximum_age_of_event</td>
    <td><code>86400</code></td>
</tr>
<tr><td colspan="3">

The age in seconds to continue to make retry attempts.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>number</code></td>
    <td width="100%">retry_attempts</td>
    <td><code>185</code></td>
</tr>
<tr><td colspan="3">

The maximum number of retry attempts to make before the request fails

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">dead_letter_queue</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

The ARN of the SQS queue specified as the target for the dead-letter queue.

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Rules



    

    

    

    

    
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">event_pattern</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify the [event pattern][eventbridge-event-pattern] that this rule will be triggered when an event matching the pattern occurs

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>map(string)</code></td>
    <td width="100%">additional_tags</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">



    

    

    

    

    


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">description</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">



    

    

    

    

    


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">state</td>
    <td><code>"ENABLED"</code></td>
</tr>
<tr><td colspan="3">



    

    

    

    

    


</td></tr>
<tr>
    <td><code>list(object(<a href="#targets">Targets</a>))</code></td>
    <td width="100%">targets</td>
    <td></td>
</tr>
<tr><td colspan="3">

Specify up to 5 targets to send the event to when the rule is triggered

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>



#### Targets

Specify up to 5 targets to send the event to when the rule is triggered

    

    

    

    

    
**Since:** 1.0.0
        
<table><thead><tr><th>Type</th><th align="left" width="100%">Name</th><th>Default&nbsp;Value</th></tr></thead><tbody>
        <tr>
    <td><code>string</code></td>
    <td width="100%">arn</td>
    <td></td>
</tr>
<tr><td colspan="3">

The Amazon Resource Name (ARN) of the target

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>string</code></td>
    <td width="100%">iam_role_arn</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

An execution role that EventBridge uses to send events to the target

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#configuretargetinput">ConfigureTargetInput</a>)</code></td>
    <td width="100%">configure_target_input</td>
    <td></td>
</tr>
<tr><td colspan="3">

Customize the text from an event before EventBridge passes the event to the target of a rule. Can only define only one of the following: `constant`, `input_transformer`. If this is not specified, the original event will be sent to the target

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#ecstargetconfig">EcsTargetConfig</a>)</code></td>
    <td width="100%">ecs_target_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configuration options for ECS target

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#httptargetconfig">HttpTargetConfig</a>)</code></td>
    <td width="100%">http_target_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configuration options for HTTP and api gateway target

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#redshifttargetconfig">RedshiftTargetConfig</a>)</code></td>
    <td width="100%">redshift_target_config</td>
    <td><code>null</code></td>
</tr>
<tr><td colspan="3">

Configuration options for Redshift target

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
<tr>
    <td><code>object(<a href="#retrypolicy">RetryPolicy</a>)</code></td>
    <td width="100%">retry_policy</td>
    <td><code>{}</code></td>
</tr>
<tr><td colspan="3">

Configures retry policy and dead-letter queue

    

    

    

    

    
**Since:** 1.0.0
        


</td></tr>
</tbody></table>




[eventbridge-event-pattern]: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-event-patterns.html?icmpid=docs_ev_console

[eventbridge-input-transformer]: https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-transform-target-input.html?icmpid=docs_ev_console

[fargate-platform-version]: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/platform-fargate.html


<!-- TFDOCS_EXTRAS_END -->
