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


Function Get-MonkeyEXOAttachmentPolicy{
    <#
        .SYNOPSIS
		Plugin to get information about safe attachment policy in Exchange Online

        .DESCRIPTION
		Plugin to get information about safe attachment policy in Exchange Online

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyEXOAttachmentPolicy
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
        $attachment_policy = $null
        #Check if already connected to Exchange Online
        $exo_session = Test-EXOConnection
    }
    Process{
        if($null -ne $exo_session){
            $msg = @{
                MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId, "Exchange Online safe attachment policy", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'info';
                InformationAction = $InformationAction;
                Tags = @('ExoSafeAttachmentPolicyInfo');
            }
            Write-Information @msg
            if($O365Object.ATPEnabled){
                #Enumerate Safe attachment Policy
                $attachment_policy = Get-SafeAttachmentInfo
                if($null -eq $attachment_policy){
                    $attachment_policy = @{
                        isEnabled = $false
                    }
                }
            }
            else{
                $msg = @{
                    MessageData = ($message.O365ATPNotDetected -f $O365Object.Tenant.CompanyInfo.displayName);
                    callStack = (Get-PSCallStack | Select-Object -First 1);
                    logLevel = 'warning';
                    InformationAction = $InformationAction;
                    Tags = @('ExoATPPolicyWarning');
                }
                Write-Information @msg
                #Set to null
                $attachment_policy = $null;
                break
            }
        }
    }
    End{
        if($attachment_policy){
            $attachment_policy.PSObject.TypeNames.Insert(0,'Monkey365.ExchangeOnline.AttachmentPolicy')
            [pscustomobject]$obj = @{
                Data = $attachment_policy
            }
            $returnData.o365_exo_safe_attachment_info = $obj
        }
        else{
            $msg = @{
                MessageData = ($message.MonkeyEmptyResponseMessage -f "Exchange Online safe attachment policy", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'warning';
                InformationAction = $InformationAction;
                Tags = @('ExoSafeAttachmentPolicyEmptyResponse');
            }
            Write-Warning @msg
        }
    }
}
