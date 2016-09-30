module SignupForm exposing (..)

-- This is where our Elm logic lives.`module SignupForm` declares that this is
-- the SignupForm module, which is how other modules will reference this one
-- if they want to import it and reuse its code.

import Html.App


-- Elm’s "import" keyword works similarly to "require" in node.js.

import Html exposing (..)


-- The “exposing (..)” option says that we want to bring the Html module’s contents
-- into this file’s current namespace, so that instead of writing out
-- Html.form and Html.label we can use "form" and "label" without the "Html."

import Html.Events exposing (..)


-- This works the same way; we also want to import the entire
-- Html.Events module into the current namespace.

import Html.Attributes exposing (id, type', for, value, class)


-- With this import we are only bringing a few specific functions into our
-- namespace, specifically "id", "type'", "for", "value", and "class".

import Http
import Task exposing (Task)
import Json.Decode exposing (succeed)


view model =
    form [ id "signup-form" ]
        [ h1 [] [ text "Sensational Signup Form" ]
        , label [ for "username-field" ] [ text "username: " ]
        , input
            [ id "username-field"
            , type' "text"
            , value model.username
            , onInput (\str -> { msgType = "SET_USERNAME", payload = str })
            ]
            []
        , div [ class "validation-error" ] [ text (viewUsernameErrors model) ]
        , label [ for "password" ] [ text "password: " ]
        , input
            [ id "password-field"
            , type' "password"
            , value model.password
            , onInput (\str -> { msgType = "SET_PASSWORD", payload = str })
            ]
            []
        , div [ class "validation-error" ] [ text model.errors.password ]
        , div [ class "signup-button", onClick { msgType = "VALIDATE", payload = "" } ] [ text "Sign Up!" ]
        ]


viewUsernameErrors model =
    if model.errors.usernameTaken then
        "That username is taken!"
    else
        model.errors.username



-- Take a look at this starting model we’re passing to our view function.
-- Note that in Elm syntax, we use = to separate fields from values
-- instead of : like JavaScript uses for its object literals.


getErrors model =
    { username =
        if model.username == "" then
            "Please enter a username!"
        else
            ""
    , password =
        if model.password == "" then
            "Please enter a password!"
        else
            ""
    , usernameTaken = model.errors.usernameTaken
    }


update msg model =
    if msg.msgType == "VALIDATE" then
        let
            url =
                "https://api.github.com/users/" ++ model.username

            failureToMsg err =
                { msgType = "USERNAME_AVAILABLE", payload = "" }

            successToMsg result =
                { msgType = "USERNAME_TAKEN", payload = "" }

            request =
                Http.get (succeed "") url

            cmd =
                Task.perform failureToMsg successToMsg request
        in
            ( { model | errors = getErrors model }, cmd )
    else if msg.msgType == "SET_USERNAME" then
        ( { model | username = msg.payload }, Cmd.none )
    else if msg.msgType == "SET_PASSWORD" then
        ( { model | password = msg.payload }, Cmd.none )
    else if msg.msgType == "USERNAME_TAKEN" then
        ( withUsernameTaken True model, Cmd.none )
    else if msg.msgType == "USERNAME_AVAILABLE" then
        ( withUsernameTaken False model, Cmd.none )
    else
        ( model, Cmd.none )


withUsernameTaken isTaken model =
    let
        currentErrors =
            model.errors

        newErrors =
            { currentErrors | usernameTaken = isTaken }
    in
        { model | errors = newErrors }


initialErrors =
    { username = "", password = "", usernameTaken = False }


initialModel =
    { username = "", password = "", errors = initialErrors }


main =
    Html.App.program
        { init = ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = \_ -> Sub.none
        }

