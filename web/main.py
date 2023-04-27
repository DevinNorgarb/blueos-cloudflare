#! /usr/bin/env python3
import logging
import shutil
import subprocess
import time
from enum import Enum
from pathlib import Path
from typing import Any

import appdirs
import uvicorn
from fastapi import FastAPI, HTTPException, status, BackgroundTasks
import subprocess
from fastapi.responses import HTMLResponse, PlainTextResponse
from fastapi_versioning import VersionedFastAPI, version
from fastapi.staticfiles import StaticFiles
from loguru import logger
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

SERVICE_NAME = "cloudflaremanager"

app = FastAPI(
    title="Cloudflare ",
    description="Cloudflare is an extension to provice ZeroTier connectivity to BlueOS",
)
logger.info("Starting Cloudflare!")

def run_command(command: str, check: bool = True) -> "subprocess.CompletedProcess['str']":
    return subprocess.run(
        command,
        check=check,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        shell=True

    )
@app.get('/cloudflared', response_class=PlainTextResponse)
async def run_cloudflared_tunnel():
    cmd = ["cloudflared", "tunnel", "--url", "http://localhost:80", "&"]
#     process = subprocess.Popen(
#         cmd,
#         stdout=subprocess.PIPE,
#         stderr=subprocess.STDOUT,
#         bufsize=2,
#         universal_newlines=True,
#         shell=True
#     )
    command = f'cloudflared tunnel --url http://localhost:80 &'
    logger.debug(f"Running command: {command}")
    output = run_command(cmd, False)
    logger.debug(output)

    return output


#     return process.stdout
# async def run_cloudflared(background_tasks: BackgroundTasks):
#     # Execute Cloudflared CLI command
#     cmd = 'cloudflared tunnel --url http://localhost:80'
#     process = subprocess.Popen(cmd.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
# #     return process.stdout
#     # Read stdout an        d stderr from the process and send to the logs
#     for line in iter(process.stdout.readline, b''):
#         print(line.decode(), end='')
#     for line in iter(process.stderr.readline, b''):
#         print(line.decode(), end='')


async def run_cloudflared_tunnel():
    cmd = ["cloudflared", "tunnel", "--url", "http://localhost:80"]
    result = subprocess.run(cmd, capture_output=True)
    if result.returncode == 0:
        output = result.stdout.decode('utf-8')
        url_start = output.find("https://")
        if url_start != -1:
            url_end = output.find(".trycloudflare.com", url_start)
            if url_end != -1:
                url = output[url_start:url_end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  + len(".trycloudflare.com")]
                return {"message": f"Tunnel URL: {url}"}
    return {"error": "Failed to start the Cloudflared tunnel"}

# @app.get('/cloudflared', response_class=PlainTextResponse)
# async def run_cloudflared_tunnel():
#     cmd = ["cloudflared", "tunnel", "--url", "localhost:80" ]
#     process = subprocess.Popen(
#         cmd,
#         stdout=subprocess.PIPE,
#         stderr=subprocess.STDOUT,
#         bufsize=1,
#         universal_newlines=True,
#         shell=False
#     )
#
#     async def generate():
#         while True:
#             output = process.stdout.readline()
#             if not output and process.poll() is not None:
#                 break
#             yield output
#
#     return generate()
# @app.post('/cloudflared')
# async def start_cloudflared(background_tasks: BackgroundTasks):
#     # Start long-running process in the background
#     background_tasks.add_task(run_cloudflared, background_tasks)
#
#     # Send response indicating that the process has started
#     return {"message": "Cloudflared process started in the background."}, 200

@app.post("/cloudflared/tunnels", status_code=status.HTTP_200_OK)
@version(1, 0)
async def command_leave(network: str) -> Any:
    command = f'cloudflared tunnel list'
    logger.debug(f"Running command: {command}")
    output = run_command(command, False)
    return output

# @app.get("/command/info", status_code=status.HTTP_200_OK)
# @version(1, 0)
# async def command_info() -> Any:
#     command = f'cloudflared tunnel list'
#     logger.debug(f"Running command: {command}")
#     output = run_command(command, False)
#     return output

# @app.get("/command/login", status_code=status.HTTP_200_OK)
# @version(1, 0)
# async def command_info() -> Any:
#     command = f'cloudflared tunnel login'
#     logger.debug(f"Running command: {command}")
#     output = run_command(command, False)
#     return output


app = VersionedFastAPI(app, version="1.0.0", prefix_format="/v{major}.{minor}", enable_latest=True)

app.mount("/", StaticFiles(directory="static", html=True), name="static")

if __name__ == "__main__":
    # Running uvicorn with log disabled so loguru can handle it
    uvicorn.run("main:app", host="0.0.0.0", port=56489, log_config=None,reload=True)
