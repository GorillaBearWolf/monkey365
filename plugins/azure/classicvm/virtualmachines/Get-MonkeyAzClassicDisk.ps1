﻿# Monkey365 - the PowerShell Cloud Security Tool for Azure and Microsoft 365 (copyright 2022) by Juan Garrido
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


Function Get-MonkeyAzClassicDisk{
    <#
        .SYNOPSIS
		Plugin to get classic disks info from Azure

        .DESCRIPTION
		Plugin to get classic disks info from Azure

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyAzClassicDisk
            Version     : 1.0

        .LINK
            https://github.com/silverhack/monkey365
    #>

    [cmdletbinding()]
    Param (
            [Parameter(Mandatory= $false, HelpMessage="Background Plugin ID")]
            [String]$pluginId
    )
    Begin{
        #Import Localized data
        $LocalizedDataParams = $O365Object.LocalizedDataParams
        Import-LocalizedData @LocalizedDataParams;
        #Get Environment
        $Environment = $O365Object.Environment
        #Get Azure Active Directory Auth
        $rm_auth = $O365Object.auth_tokens.ResourceManager
        $ClassicStorageConfig = $O365Object.internal_config.resourceManager | Where-Object {$_.name -eq "azureClassicStorage"} | Select-Object -ExpandProperty resource
    }
    Process{
        $msg = @{
            MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId, "Azure classic disks", $O365Object.current_subscription.DisplayName);
            callStack = (Get-PSCallStack | Select-Object -First 1);
            logLevel = 'info';
            InformationAction = $InformationAction;
            Tags = @('AzureClassicDisksInfo');
        }
        Write-Information @msg
        #List All classic disks
        $params = @{
            Authentication = $rm_auth;
            Provider = $ClassicStorageConfig.Provider;
            ObjectType = 'disks';
            Environment = $Environment;
            ContentType = 'application/json';
            Method = "GET";
            APIVersion = $ClassicStorageConfig.api_version;
        }
        $ClassicDisks = Get-MonkeyRMObject @params
    }
    End{
        if($ClassicDisks){
            $ClassicDisks.PSObject.TypeNames.Insert(0,'Monkey365.Azure.ClassicDisks')
            [pscustomobject]$obj = @{
                Data = $ClassicDisks
            }
            $returnData.az_classic_disks = $obj
        }
        else{
            $msg = @{
                MessageData = ($message.MonkeyEmptyResponseMessage -f "Azure classic disks", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'warning';
                InformationAction = $InformationAction;
                Tags = @('AzureClassicDisksEmptyResponse');
            }
            Write-Warning @msg
        }
    }
}
