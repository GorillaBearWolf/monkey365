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


Function Get-MonkeyTeamsGuestMeetingConfiguration{
    <#
        .SYNOPSIS
		Plugin to get information about Teams guest meeting configuration

        .DESCRIPTION
		Plugin to get information about Teams guest meeting configuration

        .INPUTS

        .OUTPUTS

        .EXAMPLE

        .NOTES
	        Author		: Juan Garrido
            Twitter		: @tr1ana
            File Name	: Get-MonkeyTeamsGuestMeetingConfiguration
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
        #Getting environment
        $Environment = $O365Object.Environment
        #Get Access Token from Teams
        $access_token = $O365Object.auth_tokens.Teams
        $guest_meet_conf= $null
    }
    Process{
        if($null -ne $access_token){
            $msg = @{
                MessageData = ($message.MonkeyGenericTaskMessage -f $pluginId, "Microsoft 365 Teams: Guest meeting configuration", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'info';
                InformationAction = $InformationAction;
                Tags = @('TeamsGuestSettings');
            }
            Write-Information @msg
            $params = @{
                Authentication = $access_token;
                InternalPath = 'PowerShell';
                ObjectType = "TeamsGuestMeetingConfiguration";
                AdminDomain = 'common';
                Environment = $Environment;
                Method = "GET";
            }
            $guest_meet_conf = Get-TeamsObject @params
        }
    }
    End{
        if($guest_meet_conf){
            $guest_meet_conf.PSObject.TypeNames.Insert(0,'Monkey365.Teams.Guest.Meeting.Configuration')
            [pscustomobject]$obj = @{
                Data = $guest_meet_conf
            }
            $returnData.o365_teams_guest_meeting_conf = $obj
        }
        else{
            $msg = @{
                MessageData = ($message.MonkeyEmptyResponseMessage -f "Microsoft 365 Teams: Guest meeting configuration", $O365Object.TenantID);
                callStack = (Get-PSCallStack | Select-Object -First 1);
                logLevel = 'warning';
                InformationAction = $InformationAction;
                Tags = @('TeamsGuestMeetingEmptyResponse');
            }
            Write-Warning @msg
        }
    }
}
