import requests
import time
import subprocess
import sys
import os
import stat
import logging

from pydantic import BaseModel
from configparser import ConfigParser


URL_BASE: str = None
TARGET_ID: str = None
secret_access_key: str = None
poll_frequency_seconds: float = None
CHECK_FILE_PERMISSIONS = True


log = None


class CmdRequest(BaseModel):
    """
    DTO for command requests
    """
    target: str
    cmd: str


class CmdResult(BaseModel):
    """
    DTO for command results
    """
    target: str
    stdout: str
    exit_code: int


def check_for_command():
    """
    connect to server to check if a new command is pending to be executed
    in such a case we check if target matches our id in order to proceed
    to execute the command
    """
    headers = {'access-token': secret_access_key}
    response = requests.get("{}/cmd/{}".format(URL_BASE, TARGET_ID), headers=headers)
    if response.status_code == 200 and response.json() is not None:
        cmd_request = response.json()
        if "target" in cmd_request:
            if cmd_request["target"] == TARGET_ID:
                log.info("target is {}, target match".format(cmd_request["target"]))
                cmd_result = execute_command(cmd_request)
                notify_result(cmd_result)
            else:
                log.debug("target is {}, target does not match".format(cmd_request["target"]))
    else:
        log.info("waiting for command...")


def execute_command(cmd_request):
    """
    executes a command and returns the output and the exit code
    """
    p = subprocess.Popen(cmd_request["cmd"], shell=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    stdout = ""
    for line in p.stdout.readlines():
        stdout += str(line)
    exit_code = p.wait()
    cmd_result = CmdResult(target=TARGET_ID, stdout=stdout, exit_code=exit_code)
    return cmd_result


def notify_result(cmd_result: CmdResult):
    """
    notifies the result of a command execution
    """
    log.info("sending response: {}".format(cmd_result.json()))
    headers = {'access-token': secret_access_key}
    requests.post("{}/result".format(URL_BASE), json=cmd_result.dict(), headers=headers)


def load_configuration():
    if len(sys.argv) != 2:
        log.error("Usage: {} path-to-config-file".format(sys.argv[0]))
        exit(1)

    config_file_path = sys.argv[1]
    if os.path.isfile(config_file_path) is False:
        log.error("cannot find config file at '{}'".format(config_file_path))
        exit(1)

    if CHECK_FILE_PERMISSIONS:
        expected_file_permissions = "400"
        file_permissions = str(oct(stat.S_IMODE(os.lstat(config_file_path).st_mode)))[2:]
        if file_permissions != expected_file_permissions:
            log.error("wrong file permissions for configuration file, expected: '{}', actual: '{}'"
                  .format(expected_file_permissions, file_permissions))
            exit(1)

    config = ConfigParser();
    config.read(config_file_path)
    global URL_BASE, TARGET_ID, poll_frequency_seconds, secret_access_key
    URL_BASE = config.get("general", "server_url")
    if URL_BASE.lower().startswith("https") is False:
        if URL_BASE.lower().startswith("http://127.0.0.1") is False:
            log.error("protocol HTTP (without TLS) is only allowed for testing purposes")
            exit(1)

    TARGET_ID = config.get("general", "target_id")
    poll_frequency_seconds = float(config.get("general", "poll_frequency_seconds"))
    secret_access_key = config.get("general", "secret_access_key")


def enter_loop():
    """
    we check for new commands every poll_frequency_seconds
    """
    while True:
        try:
            check_for_command()
        except Exception as e:
            log.error(e)

        time.sleep(poll_frequency_seconds)


def init_logger():
    global log
    formatter = logging.Formatter(fmt='%(asctime)s %(threadName)s %(levelname)s %(filename)s:%(lineno)d %(message)s')
    log = logging.getLogger()
    log.setLevel(logging.DEBUG)
    stdout = logging.StreamHandler(stream=sys.stdout)
    stdout.setLevel(logging.DEBUG)
    stdout.setFormatter(formatter)
    log.addHandler(stdout)


if __name__ == "__main__":
    init_logger()
    log.info("Gateway status is booting up")
    load_configuration()
    enter_loop()


