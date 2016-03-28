# Created by erikka at 3/17/16
Feature: Assessment
  As a nurse, I want to assess the patient.

      Scenario: Create assessment successfully.
          Given the nurse have the following assessment details:
                |id | fname   | mname   | lname   | age | department  | temperature | pulse_rate  | respiration_rate  | blood_pressure  | weight |chiefcomplaint |historyofpresentillness | medicationstaken | diagnosis   | reccomendation | attendingphysician|
                |1  |Josiah   |Timonera |Regencia | 19  | 1           | 37.1        | 80          | 19 breaths/minute | 90/70           | 48     | complaint     | history                | medication1      | diagnosis1  | recommendation1| 1                 |

          When  the nurse POST to the product resource url /anoncare.api/assessments/
          Then  the nurse should get a '200' response
#          And   the nurse get a field status containing "OK"
#          And   the nurse get a field message containing "OK"
#
#            Given the nurse have the following assessment details:
#                |id | age | temperature | pulse_rate  | respiration_rate  | blood_pressure  | weight |chiefcomplaint |historyofpresentillness | medicationstaken | diagnosis   | reccomendation |
#                |1  | 19  | 37.1        | 80          | 19 breaths/minute | 90/70           | 48     | complaint     | history                | medication1      | diagnosis1  | recommendation1|
#            When  the nurse POST to the product resource url /anoncare.api/assessments/
#            Then  the nurse should get a '200' response
            And   I get a field status containing "OK"
            And   I get a field message containing "OK"