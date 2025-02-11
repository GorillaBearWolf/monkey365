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


Function Get-MonkeyPurviewSupervisoryReviewPolicy{
    <#
        .SYNOPSIS
		Plugin to get information about supervisory review policy in Microsoft Purview

        .DESCRIPTION
		Plugin to get information about supervisory review policy in Microsoft Purview

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyPurviewSupervisoryReviewPolicy
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
        $supervisory_config = $supervisory_reports = $null
        #Check if already connected to Exchange Online
        $exo_session = Test-EXOConnection -ComplianceCenter
    }
    Process{
        if($null -ne $exo_session){
            $msg = @{
                MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId, "Microsoft Purview: Supervisory review policy", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'info';
                InformationAction = $InformationAction;
                Tags = @('SecCompSupervisoryPolicyInfo');
            }
            Write-Information @msg
            #Get O365 supervisory policy
            $supervisory_config = Get-SupervisoryReviewPolicyV2
            #Get O365 supervisory reports
            $supervisory_reports = Get-SupervisoryReviewOverallProgressReport
        }
    }
    End{
        if($supervisory_config){
            $supervisory_config.PSObject.TypeNames.Insert(0,'Monkey365.Purview.supervisoryPolicy')
            [pscustomobject]$obj = @{
                Data = $supervisory_config
            }
            $returnData.o365_secomp_supervisory_policy = $obj
        }
        else{
            $msg = @{
                MessageData = ($message.MonkeyEmptyResponseMessage -f "Microsoft Purview: Supervisory review policy", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'warning';
                InformationAction = $InformationAction;
                Tags = @('SecCompSupervisoryPolicyEmptyResponse');
            }
            Write-Warning @msg
        }
        #Return supervisory reports
        if($supervisory_reports){
            $supervisory_reports.PSObject.TypeNames.Insert(0,'Monkey365.Purview.supervisoryReports')
            [pscustomobject]$obj = @{
                Data = $supervisory_reports
            }
            $returnData.o365_secomp_supervisory_reports = $obj
        }
        else{
            $msg = @{
                MessageData = ($message.MonkeyEmptyResponseMessage -f "Microsoft Purview: Supervisory reports", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'verbose';
                InformationAction = $InformationAction;
                Tags = @('SecCompSupervisoryPolicyEmptyResponse');
            }
            Write-Verbose @msg
        }
    }
}
