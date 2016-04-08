create table Role (
    id serial8 primary key,
    rolename text
);


create table Userinfo (
    id serial8 primary key,
    fname text not null,
    mname text not null,
    lname text not null,
    email text not null,
    username text unique not null,
    password text not null,
    role_id int references Role(id),
     is_available boolean
  );

create table College(
  id serial8 primary key,
  college_name text not null,
  is_active boolean default True
);

create table Department(
  id serial8 primary key,
  department_name text not null,
  college_id int references College(id),
  is_active boolean default True
);

create table Vital_signs  (
  id serial8 primary key,
  temperature float,
  pulse_rate float,
  respiration_rate text,
  blood_pressure text,
  weight float
);

create table Personal_history(
  id serial8 primary key,
  smoking text,
  allergies text,
  alcohol text,
  medication_taken text,
  drugs text,
  done BOOLEAN
);


create table Patient_type(
    id serial8 primary key,
    type text
);


create table Personal_info(
    id serial8 primary key,
    height text,
    weight float,
    date_of_birth text,
    civil_status text,
    name_of_guardian text,
    home_address text
);

create table Pulmonary(
    id serial8 primary key,
    cough text,
    dyspnea text,
    hemoptysis text,
    tb_exposure text
);

create table Gut(
    id serial8 primary key,
    frequency text,
    flank_plan text,
    discharge text,
    dysuria text,
    nocturia text,
    dec_urine_amount text
);

create table Illness(
  id serial8 primary key,
  asthma text,
  ptb text,
  heart_problem text,
  hepatitis_a_b text,
  chicken_pox text,
  mumps text,
  typhoid_fever text
);

create table Cardiac(
  id serial8 PRIMARY KEY,
  chest_pain text,
  palpitations text,
  pedal_edema text,
  orthopnea text,
  nocturnal_dyspnea text
);

create table Neurologic(
  id serial8 UNIQUE PRIMARY KEY,
  headache text,
  seizure text,
  dizziness text,
  loss_of_consciousness text
);
create table Patient(
    id serial8 primary key,
    fname text,
    mname text,
    lname text,
    age int,
    sex text,
    department_id int references Department(id),
    patient_type_id int references Patient_type(id),
    personal_info_id int references Personal_info(id),
    pulmonary_id int references Pulmonary(id),
    gut_id int references Gut(id),
    illness_id int references Illness(id),
    cardiac_id int references Cardiac(id),
    neurologic_id int references Neurologic(id),
    is_active BOOLEAN default True
);




create table Assessment(
  id int8 primary key,
  assessment_date timestamp default 'now',
  nameofpatient int references Patient(id),
  age int,
  department int references Department(id),
  vital_signs int references Vital_signs(id),
  chiefcomplaint text,
  historyofpresentillness text,
  medicationstaken text,
  diagnosis text,
  recommendation text,
  is_done boolean default False,
  attendingphysician int references Userinfo(id)
);



insert into College values (1,'SCS');
insert into College values (2,'COE');
insert into College values (3,'CED');
insert into College values (4,'CASS');
insert into College values (5,'SET');
insert into College values (6,'CBAA');
insert into College values (7,'CON');
insert into College values (8,'CSM');

insert into Patient_type values (1,'Student');
insert into Patient_type values (2,'Faculty');
insert into Patient_type values (3,'Staff');
insert into Patient_type values (4,'Outpatient Department');

insert into Department values (1,'Computer Science',1);

create table Final_diagnosis(
  id serial8 primary key,
  assessment_id int references Assessment(id),
  doctor_id int references Userinfo(id),
  description text
);

create table Notification(
  id serial8 primary key,
  assessment_id int references Assessment(id),
  doctor_id int references Userinfo(id),
  is_read boolean default FALSE
);

------------------------------------
-----STORED PROCEDURE FUNCTIONS-----
------------------------------------

---------------------------------------------- User Accounts Maintenance ----------------------------------------------

--[POST] Check authentication of a user
--select checkauth('fname.lname', 'pass');
--select checkauth('josiah.regencia', 'josiaheleazareregencia');

create or replace function checkauth(in par_username text, in par_password text) returns text as
$$
  declare
    loc_id bigint;
    loc_username text;
    loc_password text;
    loc_response text;
  begin

    select into loc_username username
    from Userinfo
    where username = par_username and password = par_password;

    select into loc_password password
    from Userinfo
    where username = par_username and password = par_password;

    if loc_username isnull or loc_password isnull or loc_username ='' or loc_password='' then
      loc_response = 'Invalid Username or Password';
    else
      loc_response = 'Successfully logged in.';
    end if;
    return loc_response;

  end;
$$
  language 'plpgsql';

--select getpassword('josiah.regencia');
create or replace function getpassword(par_username text) returns text as
$$
  declare
    loc_password text;
  begin
     select into loc_password password
     from Userinfo
     where username = par_username;

    if loc_password isnull then
       loc_password = 'null';
     end if;
     return loc_password;
 end;
$$
 language 'plpgsql';

--  select newrole('doctor');
--  select newrole('nurse');
--  select newrole('system administrator');
create or replace function newrole(par_rolename  text) returns text as
$$
  declare
    loc_name text;
    loc_res text;
  begin

    select into loc_name rolename
    from Role
    where rolename = par_rolename;

    if loc_name isnull then
      insert into Role(rolename) values (par_rolename);
      loc_res = 'OK';

    else
      loc_res = 'EXISTED';

    end if;
      return loc_res;
  end;
$$
 language 'plpgsql';

--[POST] Create user info
--select newuserinfo('Josiah', 'Timonera', 'Regencia', 'jetregencia@gmail.com', 'josiah.regencia', 'k6bkW9nUoO8^&C+~', true);
create or replace function newuserinfo(par_fname text, par_mname text, par_lname text,
                                par_email text, par_username text,
                                par_password text, par_role int, par_available boolean)
                                 returns text as
$$

    declare
        loc_res text;

    begin

--        username := par_fname || '.' || par_lname;
--        random_password := generate_password();

       insert into Userinfo (fname, mname, lname, email, username, password, role_id, is_available)
       values (par_fname, par_mname, par_lname, par_email, par_username, par_password, par_role, par_available);


       loc_res = 'OK';
       return loc_res;
  end;
$$
 language 'plpgsql';

--Generates password of a user
create or replace function generate_password() returns text as
 $$
    declare
        characters text;
        random_password text;
        len int4;
        placevalue int4;

    begin
        characters := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789~!@#$%^&*()+=';
        len := length(characters);
        random_password := '';


        while(length(random_password) < 16) loop

            placevalue := int4(random() * len);
            random_password := random_password || substr(characters, placevalue + 1, 1);

        end loop;

        return random_password;
    end;
$$
  language 'plpgsql';

--[GET] Retrieve information of users
--select * from getUserinfo();
create or replace function getuserinfo(out text, out text, out text, out text, out text)
                                              returns setof record as
$$
    select fname, mname, lname, email, username
    from Userinfo;
$$
  language 'sql';

--[GET] Retrieve information of a specific user
--select getuserinfoid(1);
create or replace function getuserinfoid(in par_id int, out text, out text, out text, out text,
                                                 out text) returns setof record as
$$
    select fname, mname, lname, email, username from Userinfo where par_id = id;
$$
  language 'sql';

--[PUT] Update password of a user
--select updatepassword(1,'pass1');
create or replace function updatepassword(in par_id int, in par_new_password text) returns text as
  $$
    declare
      response text;

    begin
      update Userinfo set password = par_new_password where id = par_id;
      response := 'OK';

      return response;
    end;
  $$
  language 'plpgsql';

---------------------------------------------- END of User Accounts Maintenance ----------------------------------------------



-------------------------------------------------------- Patient File -----------------------------------------------------
--[POST] Create patient file
--select * from newpatient(1, 'Mary Grace', 'Pasco', 'Cabolbol', 19 ,'female', 1, 1 , '4ft', 45, 'august 13 1995', 'single', 'Juan Manalo', 'iligan city', 'mild', 'none' , 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', 'none', TRUE)
create or replace function newpatient(par_id int, par_fname text, par_mname text, par_lname text, par_age int, par_sex text,
                                      par_department_id int, par_patient_type_id int, par_height text, par_weight float, par_date_of_birth text,
                                      par_civil_status text, par_name_of_guardian text, par_home_address text, par_cough text, par_dyspnea text,
                                      par_hemoptysis text, par_tb_exposure text, par_frequency text, par_flank_plan text, par_discharge text,
                                      par_dysuria text, par_nocturia text, par_dec_urine_amount text, par_asthma text, par_ptb text,
                                      par_heart_problem text, par_hepatitis_a_b text, par_chicken_pox text, par_mumps text, par_typhoid_fever text,
                                      par_chest_pain text, par_palpitations text, par_pedal_edema text, par_orthopnea text, par_nocturnal_dyspnea text,
                                      par_headache text, par_seizure text, par_dizziness text, par_loss_of_consciousness text, par_is_active boolean) returns text as
$$
  declare
      loc_fname text;
      loc_mname text;
      loc_lname text;
      loc_res text;
      loc_id1 int;
      loc_id2 int;
      loc_id3 int;
      loc_id4 int;
      loc_id5 int;
      loc_id6 int;
      loc_id7 int;

  begin

      select into loc_id1 id from Personal_info where id = par_id;
      select into loc_id2 id from Pulmonary where id = par_id;
      select into loc_id3 id from Gut where id = par_id;
      select into loc_id4 id from Illness where id = par_id;
      select into loc_id5 id from Cardiac where id = par_id;
      select into loc_id6 id from Neurologic where id = par_id;
      select into loc_id7 id from Patient where id = par_id;
      SELECT INTO loc_fname fname from Patient where fname = par_fname AND mname = par_mname AND lname = par_lname;
      if par_id isnull or par_fname = ''or par_mname = '' or par_lname = '' or par_age isnull or par_sex = '' or par_department_id isnull or
         par_patient_type_id isnull or par_height isnull or par_weight isnull or par_date_of_birth = '' or par_civil_status = '' or
         par_name_of_guardian = '' or par_home_address = '' or par_cough = '' or par_dyspnea = '' or par_hemoptysis = '' or
         par_tb_exposure = '' or par_frequency = '' or par_flank_plan = '' or par_discharge = '' or par_dysuria = '' or
         par_nocturia = '' or par_dec_urine_amount = '' or par_asthma = '' or par_ptb = '' or par_heart_problem = '' or
         par_hepatitis_a_b = '' or par_chicken_pox = '' or par_mumps = '' or par_typhoid_fever = '' or par_chest_pain = '' or
         par_palpitations = '' or par_pedal_edema = '' or par_orthopnea = '' or par_nocturnal_dyspnea = '' or par_headache = '' or
         par_seizure = '' or par_dizziness = '' or par_loss_of_consciousness = ''  then
         loc_res = 'Please fill up the required data';
      elsif loc_fname isnull and loc_id1 isnull and loc_id2 isnull and loc_id3 isnull and loc_id4 isnull and loc_id5 isnull and loc_id6 isnull and loc_id7 isnull then
          insert into Personal_info(id, height, weight, date_of_birth, civil_status, name_of_guardian, home_address)
              values (par_id, par_height, par_weight, par_date_of_birth, par_civil_status, par_name_of_guardian, par_home_address);
          insert into Pulmonary(id, cough, dyspnea, hemoptysis, tb_exposure)
              values (par_id, par_cough, par_dyspnea, par_hemoptysis, par_tb_exposure);
          insert into Gut(id, frequency, flank_plan, discharge, dysuria, nocturia, dec_urine_amount)
              values (par_id, par_frequency, par_flank_plan, par_discharge, par_dysuria, par_nocturia, par_dec_urine_amount);
          insert into Illness(id, asthma, ptb, heart_problem, hepatitis_a_b, chicken_pox, mumps, typhoid_fever)
              values (par_id, par_asthma, par_ptb, par_heart_problem, par_hepatitis_a_b, par_chicken_pox, par_mumps, par_typhoid_fever);
          insert into Cardiac(id, chest_pain, palpitations, pedal_edema, orthopnea, nocturnal_dyspnea)
              values (par_id, par_chest_pain, par_palpitations, par_pedal_edema, par_orthopnea, par_nocturnal_dyspnea);
          insert into Neurologic(id, headache, seizure, dizziness, loss_of_consciousness)
              values (par_id, par_headache, par_seizure, par_dizziness, par_loss_of_consciousness);
          insert into Patient(id, fname, mname, lname, age, sex, department_id, patient_type_id, personal_info_id, pulmonary_id, gut_id, illness_id, cardiac_id, neurologic_id, is_active)
              values (par_id, par_fname, par_mname, par_lname, par_age, par_sex, par_department_id, par_patient_type_id, par_id, par_id, par_id, par_id, par_id, par_id, par_is_active);

          loc_res = 'OK';
      else
          loc_res = 'Patient already EXISTED';
      end if;
      return loc_res;
  end;
$$
  language 'plpgsql';

--[GET] patient file
--select * from get_patientfileId(1);
create or replace function get_patientfileId(in par_id int, out text, out text, out text, out int, out text,
                                         out text, out float, out text, out text, out text,
                                         out text, out text, out text, out text, out text,
                                         out text, out text, out text, out text, out text,
                                         out text, out text, out text, out text, out text,
                                         out text, out text, out text, out text, out text,
                                         out text, out text, out text, out text, out text,
                                         out text, out text) returns setof record as
$$
  select Patient.fname, Patient.mname, Patient.lname, Patient.age, Patient.sex,
         Personal_info.height, Personal_info.weight, Personal_info.date_of_birth, Personal_info.civil_status, Personal_info.name_of_guardian,
         Personal_info.home_address, Pulmonary.cough, Pulmonary.dyspnea, Pulmonary.hemoptysis, Pulmonary.tb_exposure,
         Gut.frequency, Gut.flank_plan, Gut.discharge, Gut.dysuria, Gut.nocturia,
         Gut.dec_urine_amount, Illness.asthma, Illness.ptb, Illness.heart_problem, Illness.hepatitis_a_b,
         Illness.chicken_pox, Illness.mumps, Illness.typhoid_fever,Cardiac.chest_pain, Cardiac.palpitations,
         Cardiac.pedal_edema, Cardiac.orthopnea, Cardiac.nocturnal_dyspnea, Neurologic.headache, Neurologic.seizure,
         Neurologic.dizziness, Neurologic.loss_of_consciousness
  from Patient, Personal_info, Pulmonary, Gut, Illness, Cardiac, Neurologic
  where Patient.id = par_id AND Personal_info.id = Patient.personal_info_id AND Pulmonary.id = Patient.pulmonary_id AND
        Gut.id = Patient.gut_id AND Illness.id = Patient.illness_id AND Cardiac.id = Patient.cardiac_id AND Neurologic.id = Patient.neurologic_id;
$$
  language 'sql';

--[GET] Retrieve the type of patient.
--select getpatienttypeID(1);
create or replace function getpatienttypeID(in par_id int, out text) returns text as
$$
  select type from Patient_type where id = par_id;
$$
  language 'sql';

-----------------------------------------------------END of Patient File --------------------------------------------------


-------------------------------------------------------- Assessment -------------------------------------------------------
--[GET] Retrieve the id number of a patient
--select retrievePatientID('Josiah','Timonera','Regencia');
create or replace function retrievePatientID(in par_fname text, in par_mname text, in par_lname text) returns bigint as
$$
  declare
      loc_id bigint;
  begin
      select into loc_id id from Patient where lower(fname) = lower(par_fname) and lower(mname) = lower(par_mname) and lower(lname) = lower(par_lname);
      return loc_id;
  end;
$$
  language 'plpgsql';

-- [POST] Create new assessment
-- select new_assessment(1,'Josiah','Timonera','Regencia', 19, 1, 37.1, 80, '19 breaths/minute', '90/70', 48, 'complaint', 'history', 'medication1', 'diagnosis1','recommendation1', 1);
create or replace function new_assessment(in par_id int, in par_fname text, in par_mname text, in par_lname text, in par_age int, in par_department int,
in par_temperature float, in par_pulse_rate float, in par_respiration_rate text, in par_blood_pressure text, in par_weight float,
in par_chiefcomplaint text, in par_historyofpresentillness text, in par_medicationstaken text,
in par_diagnosis text, in par_recommendation text, in par_attendingphysician int) returns text as
 $$
  declare
    loc_id1 int;
    loc_id2 int;
    loc_res text;
    loc_patientID bigint;
  begin
    select into loc_id1 id from Vital_signs where id = par_id;
    select into loc_id2 id from Assessment where id = par_id;

    if par_fname = '' or
       par_mname = '' or
       par_lname = '' or
       par_chiefcomplaint = '' or
       par_medicationstaken = '' or
       par_diagnosis = '' then
      loc_res = 'ERROR';

    elsif loc_id1 isnull and loc_id2 isnull then
        insert into Vital_signs(id, temperature,pulse_rate,respiration_rate,blood_pressure,weight)
          values (par_id, par_temperature,par_pulse_rate,par_respiration_rate,par_blood_pressure , par_weight );

        loc_patientID := retrievepatientID(par_fname,par_mname,par_lname);

        insert into Assessment ( id, nameofpatient, age, department,vital_signs ,chiefcomplaint ,
        historyofpresentillness ,medicationstaken ,diagnosis ,recommendation,attendingphysician )
        values ( par_id, loc_patientID, par_age, par_department, par_id,
        par_chiefcomplaint, par_historyofpresentillness, par_medicationstaken, par_diagnosis,
        par_recommendation, par_attendingphysician);

        loc_res = 'OK';

    else
      loc_res = 'ID EXISTS';

    end if;
    return loc_res;

  end;
 $$
  language 'plpgsql';

--[GET] Retrieve assessment of a specific patient
--select getassessmentID(1);
create or replace function getassessmentID(in par_id int, out timestamp, out int,out int,out int,out float,
  out float, out text ,out text ,out float, out text,out text,out text,out text,out text,out int)
  returns setof record as
$$

  select assessment_date,
    nameofpatient,
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
    attendingphysician
  from Assessment, Vital_signs
  where Assessment.id = par_id and Vital_signs.id = par_id;

$$
  language 'sql';

-- [GET] Retrieve assessments of all patients
--select getallassessment();
create or replace function getallassessment(out bigint, out timestamp, out int,out int,out int,out float,
  out float, out text ,out text ,out float, out text,out text,out text,out text,out text,out int) returns setof record as
$$

  select Assessment.id,
    assessment_date,
    nameofpatient,
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
    attendingphysician
  from Assessment, Vital_signs
  where Assessment.id = Vital_signs.id

$$
  language 'sql';

-- [GET] Retrieve all assessment of a specific patient
--select getallassessmentID(1);
create or replace function getallassessmentID(in par_id int, out timestamp, out int,out int,out int,out float,
  out float, out text ,out text ,out float, out text,out text,out text,out text,out text,out int) returns setof record as
$$
  select assessment_date,
    nameofpatient,
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
    attendingphysician
  from Assessment, Vital_signs
  where Assessment.nameofpatient = par_id and Assessment.id = Vital_signs.id

$$
  language 'sql';

--[PUT] Update assessment of patient
--select update_assessment(1,'Josiah','Timonera','Regencia', 19, 1, 37.1, 80, '19 breaths/minute', '90/70', 48, 'complaint', 'history', 'medication1', 'diagnosis11','recommendation11', 1);
create or replace function update_assessment(in par_id int, in par_fname text, in par_mname text, in par_lname text, in par_age int, in par_department int,
in par_temperature float, in par_pulse_rate float, in par_respiration_rate text, in par_blood_pressure text, in par_weight float,
in par_chiefcomplaint text, in par_historyofpresentillness text, in par_medicationstaken text,
in par_diagnosis text, in par_recommendation text, in par_attendingphysician int) returns text as
 $$
  declare
    loc_res text;
  begin

    update Assessment
    set
      diagnosis = par_diagnosis,
      recommendation = par_recommendation,
      attendingphysician = par_attendingphysician
    where id = par_id;

    loc_res = 'Updated';
    return loc_res;

  end;
$$
  language 'plpgsql';

------------------------------------------------------ END Assessment -----------------------------------------------------


------------------------------------------------------- Notifications -----------------------------------------------------
--[POST] Create notification
-- select createnotify(2, 1);
create or replace function createnotify(par_assessment_id int, par_doctor_id int) returns text as
$$
  declare
      loc_response text;
      loc_id int;
  begin
        select into loc_id assessment_id from Notification where assessment_id = par_assessment_id;
        if loc_id isnull then
          insert into Notification(assessment_id, doctor_id) values (par_assessment_id, par_doctor_id);                            
          loc_response = 'OK';

        else
          loc_response = 'ID EXISTED';
        end if;
        return loc_response;
  end;
$$
  language 'plpgsql';


--[GET] get specific notification
create or replace function getnotify(in par_assessment_id int, in par_doctor_id int, out par_assessment_id int, out par_doctor_id int, out par_is_read boolean) returns setof record as
$$  
  select doctor_id, assessment_id, is_read from Notification where assessment_id=par_assessment_id and doctor_id=par_doctor_id;
$$
  language 'sql';


create or replace function update_notification(in par_assessment_id int, in par_doctor_id int) returns text as
  $$
    declare 
      loc_response text;

    begin

      update notification set is_read = 'TRUE' where assessment_id= par_assessment_id and doctor_id = par_doctor_id;
      loc_response = 'UPDATED';
      return loc_response;
    end;

  $$
    language 'plpgsql';
-----------------------------------------------------END Notifications ----------------------------------------------------

