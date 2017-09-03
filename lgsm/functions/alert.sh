#!/bin/bash
# LinuxGSM alert.sh function
# Author: Daniel Gibbs
# Website: https://gameservermanagers.com
# Description: Overall function for managing alerts.

local commandname="ALERT"
local commandaction="Alert"

fn_alert_log(){
	info_distro.sh
	info_config.sh
	info_glibc.sh
	info_messages.sh
	if [ -f "${alertlog}" ]; then
		rm "${alertlog}"
	fi

	{
		fn_info_message_head
		fn_info_message_distro
		fn_info_message_performance
		fn_info_message_disk
		fn_info_message_gameserver
		fn_info_logs
	} | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"| tee -a "${alertlog}" > /dev/null 2>&1
}

fn_alert_test(){
	fn_script_log_info "Sending test alert"
	alertsubject="Alert - ${servicename} - Test"
	alertemoji="🚧"
	alertsound="1"
	alerturl="not enabled"
	alertbody="Testing LinuxGSM Alert. No action to be taken."
}

fn_alert_restart(){
	fn_script_log_info "Sending alert: Restarted: ${executable} not running"
	alertsubject="Alert - ${servicename} - Restarted"
	alertemoji="🚨"
	alertsound="2"
	alerturl="not enabled"
	alertbody="${servicename} ${executable} not running"
}

fn_alert_restart_query(){
	fn_script_log_info "Sending alert: Restarted: ${gsquerycmd}"
	alertsubject="Alert - ${servicename} - Restarted"
	alertemoji="🚨"
	alertsound="2"
	alerturl="not enabled"
	alertbody="gsquery.py failed to query: ${gsquerycmd}"
}

fn_alert_update(){
	fn_script_log_info "Sending alert: Updated"
	alertsubject="Alert - ${servicename} - Updated"
	alertemoji="🎮"
	alertsound="1"
	alerturl="not enabled"
	alertbody="${gamename} received update"
}

fn_alert_permissions(){
	fn_script_log_info "Sending alert: Permissions error"
	alertsubject="Alert - ${servicename}: Permissions error"
	alertemoji="❗"
	alertsound="2"
	alerturl="not enabled"
	alertbody="${servicename} has permissions issues"
}

if [ "${alert}" == "permissions" ]; then
	fn_alert_permissions
elif [ "${alert}" == "restart" ]; then
	fn_alert_restart
elif [ "${alert}" == "restartquery" ]; then
	fn_alert_restart_query
elif [ "${alert}" == "test" ]; then
	fn_alert_test
elif [ "${alert}" == "update" ]; then
	fn_alert_update
fi

# Generate alert log
fn_alert_log

# Generates the more info link
if [ "${postalert}" == "on" ]&&[ -n "${postalert}" ]; then
	alertflag=1
	command_postdetails.sh
elif [ "${postalert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_warn_nl "Discord alerts not enabled"
	fn_script_log_warn "Discord alerts not enabled"
elif [ -z "${posttarget}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "posttarget not set"
	fn_script_error_warn "posttarget not set"
elif [ -z "${postdays}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "postdays not set"
	fn_script_error_warn "postdays not set"
fi

if [ "${discordalert}" == "on" ]&&[ -n "${discordalert}" ]; then
	alert_discord.sh
elif [ "${discordalert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_warn_nl "Discord alerts not enabled"
	fn_script_log_warn "Discord alerts not enabled"
elif [ -z "${discordtoken}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "Discord token not set"
	echo "	* https://github.com/GameServerManagers/LinuxGSM/wiki/Discord"
	fn_script_error_warn "Discord token not set"
fi

if [ "${emailalert}" == "on" ]&&[ -n "${email}" ]; then
	alert_email.sh
elif [ "${emailalert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_warn_nl "Email alerts not enabled"
	fn_script_log_warn "Email alerts not enabled"
elif [ -z "${email}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "Email not set"
	fn_script_log_error "Email not set"
fi

if [ "${iftttalert}" == "on" ]&&[ -n "${iftttalert}" ]; then
	alert_ifttt.sh
elif [ "${iftttalert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_warn_nl "IFTTT alerts not enabled"
	fn_script_log_warn "IFTTT alerts not enabled"
elif [ -z "${ifttttoken}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "IFTTT token not set"
	echo "	* https://github.com/GameServerManagers/LinuxGSM/wiki/IFTTT"
	fn_script_error_warn "IFTTT token not set"
fi

if [ "${mailgunalert}" == "on" ]&&[ -n "${mailgunalert}" ]; then
	alert_mailgun.sh
elif [ "${mailgunalert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_warn_nl "Mailgun alerts not enabled"
	fn_script_log_warn "Mailgun alerts not enabled"
elif [ -z "${mailguntoken}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "Mailgun token not set"
	echo "	* https://github.com/GameServerManagers/LinuxGSM/wiki/Mailgun"
	fn_script_error_warn "Mailgun token not set"
fi

if [ "${pushbulletalert}" == "on" ]&&[ -n "${pushbullettoken}" ]; then
	alert_pushbullet.sh
elif [ "${pushbulletalert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_warn_nl "Pushbullet alerts not enabled"
	fn_script_log_warn "Pushbullet alerts not enabled"
elif [ -z "${pushbullettoken}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "Pushbullet token not set"
	echo "	* https://github.com/GameServerManagers/LinuxGSM/wiki/Pushbullet"
	fn_script_error_warn "Pushbullet token not set"
fi

if [ "${pushoveralert}" == "on" ]&&[ -n "${pushoveralert}" ]; then
	alert_pushover.sh
elif [ "${pushoveralert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_warn_nl "Pushover alerts not enabled"
	fn_script_log_warn "Pushover alerts not enabled"
elif [ -z "${pushovertoken}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "Pushover token not set"
	echo "	* https://github.com/GameServerManagers/LinuxGSM/wiki/Pushover"
	fn_script_error_warn "Pushover token not set"
fi

if [ "${telegramalert}" == "on" ]&&[ -n "${telegramtoken}" ]; then
	alert_telegram.sh
elif [ "${telegramalert}" != "on" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_warn_nl "Telegram Messages not enabled"
	fn_script_log_warn "Telegram Messages not enabled"
elif [ -z "${telegramtoken}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "Telegram token not set."
	echo "	* https://github.com/GameServerManagers/LinuxGSM/wiki/Telegram"
	fn_script_error_warn "Telegram token not set."
elif [ -z "${telegramchatid}" ]&&[ "${function_selfname}" == "command_test_alert.sh" ]; then
	fn_print_error_nl "Telegram chat id not set."
	echo "	* https://github.com/GameServerManagers/LinuxGSM/wiki/Telegram"
	fn_script_error_warn "Telegram chat id not set."
fi