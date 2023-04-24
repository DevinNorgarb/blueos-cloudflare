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
from fastapi import FastAPI, HTTPException, status
from fastapi.responses import HTMLResponse
from fastapi_versioning import VersionedFastAPI, version
from fastapi.staticfiles import StaticFiles
from loguru import logger

SERVICE_NAME = "cloudflaremanager"

# logging.basicConfig(handlers=[InterceptHandler()], level=0)
#logger.add(get_new_log_path(SERVICE_NAME))

app = FastAPI(
    title="Cloudflare ",
    description="Cloudflare is an extension to provice ZeroTier connectivity to BlueOS",
)
# app.router.route_class = GenericErrorHandlingRoute
logger.info("Starting Cloudflare!")


def run_command(command: str, check: bool = True) -> "subprocess.CompletedProcess['str']":
    return subprocess.run(
        command.split(),
        check=check,
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )

@app.post('/cloudflared')
async def run_cloudflared():
    # Execute Cloudflared CLI command
    cmd = 'cloudflared tunnel --url http://localhost:80'
    result = subprocess.run(cmd.split(), stdout=subprocess.PIPE, stderr=subprocess.PIPE)

    if result.returncode != 0:
        # Send error response if command failed
        return {"error": result.stderr.decode()}, 500

    # Send response with command output
    return {"output": result.stdout.decode()}, 200


@app.post("/command/create", status_code=status.HTTP_200_OK)
@version(1, 0)
async def command_join() -> Any:
    command = f'cloudflared tunnel --url http://localhost:80 &'
    logger.debug(f"Running command: {command}")
    output = run_command(command, False)
    return output

# @app.post("/command/leave", status_code=status.HTTP_200_OK)
# @version(1, 0)
# async def command_leave(network: str) -> Any:
#     command = f'zerotier-cli leave {network}'
#     logger.debug(f"Running command: {command}")
#     output = run_command(command, False)
#     return output

@app.get("/command/info", status_code=status.HTTP_200_OK)
@version(1, 0)
async def command_info() -> Any:
    command = f'cloudflared tunnel list'
    logger.debug(f"Running command: {command}")
    output = run_command(command, False)
    return output

@app.get("/command/login", status_code=status.HTTP_200_OK)
@version(1, 0)
async def command_info() -> Any:
    command = f'cloudflared tunnel login'
    logger.debug(f"Running command: {command}")
    output = run_command(command, False)
    return output


app = VersionedFastAPI(app, version="1.0.0", prefix_format="/v{major}.{minor}", enable_latest=True)

app.mount("/", StaticFiles(directory="static", html=True), name="static")

if __name__ == "__main__":
    # Running uvicorn with log disabled so loguru can handle it
    uvicorn.run(app, host="0.0.0.0", port=56489, log_config=None)
