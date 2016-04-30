import os
from flask import Flask, jsonify, request, session, redirect, url_for
from os import sys
from models import DBconn
import json, flask
from app import app
import re                   #this is for verifying if the email is valid
import hashlib
from flask.ext.httpauth import HTTPBasicAuth


auth = HTTPBasicAuth()


def spcall(qry, param, commit=False):
    try:
        dbo = DBconn()
        cursor = dbo.getcursor()
        cursor.callproc(qry, param)
        res = cursor.fetchall()
        if commit:
            dbo.dbcommit()
        return res
    except:
        res = [("Error: " + str(sys.exc_info()[0]) + " " + str(sys.exc_info()[1]),)]
    return res


@app.route('/')
@auth.login_required
def index2():
    return 'Hello world!'


@auth.get_password
def get_password(username):
    return spcall('get_password', (username,))[0][0]



@app.after_request
def add_cors(resp):
    resp.headers['Access-Control-Allow-Origin'] = flask.request.headers.get('Origin', '*')
    resp.headers['Access-Control-Allow-Credentials'] = True
    resp.headers['Access-Control-Allow-Methods'] = 'POST, OPTIONS, GET, PUT, DELETE'
    resp.headers['Access-Control-Allow-Headers'] = flask.request.headers.get('Access-Control-Request-Headers',
                                                                             'Authorization')
    # set low for debugging
    if app.debug:
        resp.headers["Access-Control-Max-Age"] = '1'
    return resp