# Created by josiah at 3/18/16
Feature: Register User
  As a System Administrator I want to be able to register users to the system.

  Scenario: Add a new user to the system - all requirements put
    Given admin inputs:
        |fname | |mname   |  |lname|   |email                  | |username    | |password             |
        |Mike  | |Timonera|  |Dingo| |jawshaeleazar@gmail.com| |mike.dingo| |josiaheleazarregencia|

    When admin clicks the register button

    And the username 'mike.dingo' does not yet exist

    Then admin should get a '200' response

    And admin should get a status OK


#  Scenario: Add a new user - username already exists
#    Given username 'josiah.eleazar' already exists
#
#    When admin inputs:
#        |fname |  |mname  | |lname  |  |email                 | |username      | |password             |
#        |Josiah| |Regencia| |Eleazar| |jawshaeleazar@gmail.com| |josiah.eleazar| |josiaheleazarregencia|
#
#    Then admin should get a '200' response
#
#    And admin should get a status error
#
#    And admin should get a message error