
#!flask/bin/python
import os
from os import sys
from flask import Flask, jsonify, render_template, request, session, redirect
from functools import wraps
# from flask.ext.httpauth import HTTPBasicAuth
from os import sys
from models import DBconn
import json, flask
from app import app

#auth = HTTPBasicAuth()

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


@app.errorhandler(404)
def page_not_found(e):
    return 'Sorry, the page you were looking for was not found.'

@app.errorhandler(500)
def internal_server_error(e):
    return '(Error 500) Sorry, there was an internal server error.'


@app.route('/anoncare.api/login', methods=['POST'])
def login():
    data = json.loads(request.data)
    username = data['username']
    password = data['password']

    user = spcall('checkauth', (username,password, ), True)

    if 'Invalid Username or Password' in str(user[0][0]):
        return jsonify({'status': 'error', 'message': user[0][0]})
    else:
        return jsonify({'status':'OK', 'message': user[0][0]})


@app.route('/logout')
def logout():
    session.pop('logged_in', None)
    return jsonify({'status':'ok'})

#create a wrapper: this wrapper is for athenticating users
def anoncare_login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if session.get('logged_in'):
            if session['logged_in']:
                pass

        else:
            return login()

        return f(*args, **kwargs)

    return decorated

####################################################################################################

@app.route('/admin', methods=['GET', 'POST'])
@anoncare_login_required
def admin_home():
    return render_template('admin/index.html')

@app.route('/api.anoncare/question', methods=['GET'])
def get_all_questions():
    res = spcall('get_newquestion',())
    print res


@app.route('/anoncare.api/colleges/<college_id>/', methods = ['GET'])
def get_college(college_id):
    res = spcall('getcollegeID', str(college_id))

    if 'Error' in str(res[0][0]):
        return jsonify({'status': 'error', 'message': res[0][0]})

    r = res[0]
    return jsonify({"college_id": str(college_id), "college_name": str(r[0])})


# @app.route('/anoncare.api/userexists/<string:username>/', methods=['GET'])
def user_exists(username):
    users = spcall('getuserinfo', ())
    index = 0
    count = 0

    for user in users:
        if username == users[index][4]:
            count += 1

        index += 1

    if count == 1:
        # return jsonify({"exists": True})
        return True
    else:
        # return jsonify({"exists": False})
        return False


@app.route('/anoncare.api/userexists/<string:username>/', methods=['GET'])
def jsonify_user_exists(username):
    exists = user_exists(username)

    return jsonify({"exists": exists})


@app.route('/anoncare.api/users/<int:id>/', methods=['GET'])
def get_user_with_id(id):
    res = spcall("getuserinfoid", (id,), True)
    entries = []

    print "res is ", len(res)

    if len(res) != 0:
        row = res[0]
        entries.append({
                        "fname":  row[0],
                        "mname": row[1],
                        "lname": row[2],
                        "email": row[3],
                        "username": row[4]})

        print "username is ", res[0][4]

        return jsonify({"status": "ok", "message": "ok", "entries": entries})

    else:
        return jsonify({"status": "ok", "message": "No User Found"})


@app.route('/anoncare.api/user/', methods=['POST', 'GET'])
def insertuser():

    user = json.loads(request.data)

    print "user is ", user

    fname = user['fname']
    mname = user['mname']
    lname = user['lname']
    email = user['email']
    username = user['username']
    password = user['password']
    role_id = user['role_id']
    is_available = user['is_available']


    if(user_exists(username)) == True:
        return jsonify({'status': 'error'})

    else:
        spcall("newuserinfo", (fname, mname, lname, email, username, password, role_id, is_available), True)
        return jsonify({'status': 'OK'})


@app.route('/anoncare.api/vital_signs/<int:vital_signID>', methods = ['GET'])
def get_vital_signs(vital_signID):
    res = spcall('getvitalsignsID', str(vital_signID))

    if 'Error' in str(res[0][0]):
        return jsonify({'status': 'error', 'message': res[0][0]})

    r = res[0]
    return jsonify({"vital_signID": str(vital_signID),
                    "temperature (C)": str(r[0]),
                    "pulse_rate": str(r[1]),
                    "respiration_rate": str(r[2]),
                    "blood_pressure": str(r[3]),
                    "weight": str(r[4]), "message" : str(r[0][0])})

@app.route('/anoncare.api/login', methods=['POST'])
def checkauth():
    data = json.loads(request.data)

    username = data['username']
    password = data ['password']

    if user_exists(username):
        response = spcall('checkauth', (username, password))



    if 'Invalid username' in str(response[0][0]):
        return jsonify({'status': 'error', 'message': response[0][0], "username": username})

    return jsonify({'status': 'ok', 'message': response[0][0]}), 201


# @app.route('/anoncare.api/login', methods=['POST', 'GET'])
# def login_index():
#     if request.method == 'POST':
#         json_data = request.get_json(force=True)
#         username = json_data['username']
#         password = json_data['password']
#         return checkauth(username, password)
#         print password
#         print username
#     return render_template('login.html')

@app.route('/anoncare.api/notify/<int:assessment_id>/<int:doctor_id>', methods=['POST'])
def notify(assessment_id, doctor_id):
    response = spcall("createnotify", (assessment_id, doctor_id), True)

    if 'Error' in str(response[0][0]):
        return jsonify({'status': 'error', 'message': response[0][0]})

    return jsonify({'status': response[0][0]})

@app.route('/anoncare.api/patient/', methods =['POST'])
def newpatient():
    data = json.loads(request.data)
    response = spcall('newpatient', (
        data['id'],
        data['fname'],
        data['mname'],
        data['lname'],
        data['age'],
        data['sex'],
        data['department_id'],
        data['patient_type_id'],
        data['height'],
        data['weight'],
        data['date_of_birth'],
        data['civil_status'],
        data['name_of_guardian'],
        data['home_address'],
        data['cough'],
        data['dyspnea'],
        data['hemoptysis'],
        data['tb_exposure'],
        data['frequency'],
        data['flank_plan'],
        data['discharge'],
        data['dysuria'],
        data['nocturia'],
        data['dec_urine_amount'],
        data['asthma'],
        data['ptb'],
        data['heart_problem'],
        data['hepatitis_a_b'],
        data['chicken_pox'],
        data['mumps'],
        data['typhoid_fever'],
        data['chest_pain'],
        data['palpitations'],
        data['pedal_edema'],
        data['orthopnea'],
        data['nocturnal_dyspnea'],
        data['headache'],
        data['seizure'],
        data['dizziness'],
        data['loss_of_consciousness'],
        data['is_active']))

    if 'Error' in str(response[0][0]):
        return jsonify({'status': 'error', 'message': response[0][0]})

    return jsonify({'status': 'OK', 'message': response[0][0]}), 200

@app.route('/anoncare.api/patient/<id>/', methods = ['GET'])
def getpatient_file(id):
    response = spcall('get_patientfileId', [id])
    entries = []
    if len(response) == 0:
        return jsonify({"status":"OK", "message": "No patient file found", "entries":[], "count": "0"})
    else:
        row = response[0]
        entries.append({"id": id,
                        "fname": row[0],
                        "mname": row[1],
                        "lname": row[2],
                        "age": row[3],
                        "sex": row[4],
                        "height": row[5],
                        "weight": row[6],
                        "date_of_birth": row[7],
                        "civil_status": row[8],
                        "name_of_guardian": row[9],
                        "home_address": row[10],
                        "cough": row[11],
                        "dyspnea": row[12],
                        "hemoptysis": row[13],
                        "tb_exposure": row[14],
                        "frequency": row[15],
                        "flank_plan": row[16],
                        "discharge": row[17],
                        "dysuria": row[18],
                        "nocturia": row[19],
                        "dec_urine_amount": row[20],
                        "asthma": row[21],
                        "ptb": row[22],
                        "heart_problem": row[23],
                        "hepatitis_a_b": row[24],
                        "chicken_pox": row[25],
                        "mumps": row[26],
                        "typhoid_fever": row[27],
                        "chest_pain": row[28],
                        "palpitations": row[29],
                        "pedal_edema": row[30],
                        "orthopnea": row[31],
                        "nocturnal_dyspnea": row[32],
                        "headache": row[33],
                        "seizure": row[34],
                        "dizziness": row[35],
                        "loss_of_consciousness": row[36]
                        })
        return jsonify({'status': 'OK', 'message': 'OK', 'entries': entries, 'count':len(entries)})


@app.route('/anoncare.api/notify/<int:assessment_id>/<int:doctor_id>', methods=['GET'])
def getnotify(assessment_id, doctor_id):
    notification = spcall("getnotify", (assessment_id, doctor_id))

    if 'Error' in str(notification[0][0]):
        return jsonify({'status': 'error', 'message': notification[0][0]})

    records = []
    for r in notification:
        records.append({ "doctor_id": str(r[0]), "assessment_id": str(r[1]), "is_read": str(r[2]) })
    return jsonify({'status': 'Ok','entries': records, 'count': len(records) })

@app.route('/anoncare.api/referral/<int:assessment_id>/<int:doctor_id>/<int:prev_doctor>', methods=['POST'])
def doctor_referral(assessment_id, doctor_id, prev_doctor):
    update_notification = spcall("update_notification", (assessment_id, prev_doctor), True)
    update_assessment = spcall("update_assessment_attendingphysician", (assessment_id, doctor_id), True)

    if 'Unable to find assessment' in str(update_assessment[0][0]):
        return jsonify({'status':'error', 'message':update_assessment[0][0]})


    return jsonify({'status':str(update_assessment[0][0])})


@app.route('/anoncare.api/accept/<int:assessment_id>/<int:doctor_id>', methods=['POST'])
def accept_assessment(assessment_id, doctor_id):
    assessment_accept = spcall("accept_assessment", (assessment_id, doctor_id, ), True)
    assessment = spcall("getassessmentID", (assessment_id, ))

    if 'Error' in str(assessment[0][0]):
        return jsonify({'status':'error'})

    records = []

    for r in assessment:
        records.append({'assessment_id':str(r[12]), 'attendingphysician':str(r[10]), 'is_accepted':str(r[11])})

    return jsonify({'status':'ok', 'entries':records})


@app.route('/anoncare.api/assessments/<int:assessment_id>/', methods=['GET'])
def view_assessment(assessment_id):
    assessments = spcall("getassessmentID", (assessment_id, ))
    records = []

    if len(assessments) == 0:
        return jsonify({"status": "OK", "message": "No entries found", "entries": [], "count": "0"})

    elif 'Error' in str(assessments[0][0]):
        return jsonify({'status': 'error', 'message': assessments[0][0]})

    else:
        r = assessments[0]

        records.append({"assessment_date": r[0],
                        "patient_id": r[1],
                        "age": r[2],
                        "department": r[3],
                        "temperature":r[4],
                        "pulse_rate":r[5],
                        "respiration_rate":r[6],
                        "blood_pressure":r[7],
                        "weight":r[8],
                        "chief_complaint": r[9],
                        "history_of_present_illness": r[10],
                        "medications_taken": r[11],
                        "diagnosis": r[12],
                        "recommendation": r[13],
                        "attending_physician": r[14]})

        return jsonify({'status': 'OK', 'entries': records, 'count': len(records)})

@app.route('/anoncare.api/assessments/', methods=['GET'])
def view_all_assessments():
    assessments = spcall("getallassessment", ())
    records = []

    if len(assessments) == 0:
        return jsonify({"status": "OK", "message": "No entries found", "entries": [], "count": "0"})

    elif 'Error' in str(assessments[0][0]):
        return jsonify({'status': 'error', 'message': assessments[0][0]})

    else:
        for r in assessments:
            records.append({"assessment_id": r[0],
                            "assessment_date": r[1],
                            "patient_id": r[2],
                            "age": r[3],
                            "department": r[4],
                            "temperature": r[5],
                            "pulse_rate": r[6],
                            "respiration_rate": r[7],
                            "blood_pressure": r[8],
                            "weight": r[9],
                            "chief_complaint": r[10],
                            "history_of_present_illness": r[11],
                            "medications_taken": r[12],
                            "diagnosis": r[13],
                            "recommendation": r[14],
                            "attending_physician": r[15]})

        return jsonify({'status': 'OK', 'entries': records, 'count': len(records)})

@app.route('/anoncare.api/assessments/', methods = ['POST'])
def new_assessment():
    data = json.loads(request.data)

    id = data['id']
    fname = data['fname']
    mname = data['mname']
    lname = data['lname']
    age = data['age']
    department = data['department']
    temperature =  data['temperature']
    pulse_rate = data['pulse_rate']
    respiration_rate = data['respiration_rate']
    blood_pressure = data['blood_pressure']
    weight = data['weight']
    chiefcomplaint = data['chiefcomplaint']
    historyofpresentillness = data['historyofpresentillness']
    medicationstaken = data['medicationstaken']
    diagnosis = data['diagnosis']
    recommendation = data['reccomendation']
    attendingphysician = data['attendingphysician']

    response = spcall("new_assessment", (id, fname, mname, lname, age, department, temperature, pulse_rate, respiration_rate, blood_pressure, weight,
    chiefcomplaint, historyofpresentillness, medicationstaken, diagnosis, recommendation, attendingphysician, ), True)

    if 'Error' in response[0][0]:
        return jsonify({'status': 'error', 'message': response[0][0]})
    print "MESSAGE: \n", response
    return jsonify({'status': 'OK', 'message': response[0][0]})


@app.route('/anoncare.api/assessments/update/<assessment_id>/', methods=['PUT'])
def update_assessment(assessment_id):
    data = json.loads(request.data)
    print "response : ", data
    id = data.get('id', '')
    fname = data.get('fname', '')
    mname = data.get('mname', '')
    lname = data.get('lname', '')
    age = data.get('age', '')
    department = data.get('department', '')
    temperature = data.get('temperature','')
    pulse_rate = data.get('pulse_rate', '')
    respiration_rate = data.get('respiration_rate', '')
    blood_pressure = data.get('blood_pressure', '')
    weight = data.get('weight', '')
    chiefcomplaint = data.get('chiefcomplaint', '')
    historyofpresentillness = data.get('historyofpresentillness', '')
    medicationstaken = data.get('medicationstaken', '')
    diagnosis = data.get('diagnosis', '')
    recommendation = data.get('reccomendation', '')
    attendingphysician = data.get('attendingphysician', '')

    response = spcall('update_assessment', (
        id,
        fname,
        mname,
        lname,
        age,
        department,
        temperature,
        pulse_rate,
        respiration_rate,
        blood_pressure,
        weight,
        chiefcomplaint,
        historyofpresentillness,
        medicationstaken,
        diagnosis,
        recommendation,
        attendingphysician, ), True)
    print "response : ",response
    return jsonify({'status': 'OK', 'message': response[0][0]})

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


if __name__ == '__main__':
    app.run()
