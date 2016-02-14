from flask import Flask, render_template, request, flash, redirect, url_for

# from flask_restful import Resource, Api
from flask.ext.sqlalchemy import SQLAlchemy


#Create an Instance of Flask
app = Flask(__name__)

# api = Api(app)
#Include config from config.py                       username:password@localhost/db
app.config['SQLALCHEMY_DATABASE_URI']= 'postgresql://anoncare:anoncare@localhost/acdb'
app.secret_key = '23jDSJ32lzcxcwsSDWJK'
app.CSRF_ENABLED = True

#Create an instance of SQLAclhemy
db = SQLAlchemy(app)

from app import views, models