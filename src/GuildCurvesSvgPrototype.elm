port module GuildCurvesSvgPrototype exposing (Model, Msg, main)

{-| SVG safe-area trial with the same logos and controls as the CSS experiment.
Run npm run prototype:guild-svg.
-}

import Browser
import Effect.Browser.Dom as Dom
import FileStatus
import GuildIcon
import GuildName
import Html
import MyUi
import Ui
import Ui.Font


type alias Model =
    { inset : Int, zoom : Float, selected : Int }


type Msg
    = Select Int
    | Inset Int
    | Zoom Float


port prototypeState : Model -> Cmd msg


main : Program Model Model Msg
main =
    Browser.element
        { init = \flags -> ( flags, Cmd.none )
        , update =
            \msg model ->
                let
                    next =
                        case msg of
                            Select selected ->
                                { model | selected = selected }

                            Inset inset ->
                                { model | inset = inset }

                            Zoom zoom ->
                                { model | zoom = zoom }
                in
                ( next, prototypeState next )
        , subscriptions = \_ -> Sub.none
        , view = view
        }


view : Model -> Html.Html Msg
view model =
    Ui.layout
        [ Ui.background MyUi.background1
        , Ui.Font.color MyUi.font1
        , MyUi.notoSans
        , Ui.padding 24
        , Ui.behindContent (Ui.html MyUi.css)
        ]
        (Ui.column [ Ui.spacing 20 ]
            [ Ui.el [ Ui.Font.size 24, Ui.Font.bold ] (Ui.text "PROTOTYPE · SVG safe-area curves")
            , Ui.text ("Inset " ++ String.fromInt model.inset ++ "px · zoom " ++ String.fromFloat model.zoom ++ " · guild " ++ String.fromInt model.selected)
            , Ui.row [ Ui.spacing 8 ] (List.map (\inset -> control ("inset-" ++ String.fromInt inset) (Inset inset) ("Inset " ++ String.fromInt inset)) [ 0, 1, 40, 47 ])
            , Ui.row [ Ui.spacing 8 ] (List.map (\zoom -> control ("zoom-" ++ String.fromFloat zoom) (Zoom zoom) (String.fromFloat (zoom * 100) ++ "%")) [ 1, 1.25, 1.5, 2 ])
            , Ui.row [ Ui.height (Ui.px 420), MyUi.htmlStyle "zoom" (String.fromFloat model.zoom) ]
                [ Ui.el [ Ui.width (Ui.px 55), Ui.height Ui.fill ]
                    (Ui.column
                        [ Ui.width (Ui.px 56), Ui.spacing 6, Ui.paddingWith { left = 0, right = 0, top = max 6 model.inset, bottom = 0 } ]
                        (List.indexedMap (guildButton model)
                            [ ( "Avatar", Just "avatar" ), ( "Sheep Game", Just "sheep" ), ( "At Chat", Just "at-chat" ), ( "Plain Guild", Nothing ) ]
                        )
                    )
                , Ui.el [ Ui.height Ui.fill, Ui.paddingWith { left = 0, right = 0, top = model.inset, bottom = 0 } ]
                    (Ui.column
                        [ Ui.width (Ui.px 220)
                        , Ui.height Ui.fill
                        , Ui.background MyUi.background2
                        , MyUi.htmlStyle "border-radius" (String.fromInt (model.inset // 2) ++ "px 0 0 0")
                        , Ui.paddingWith { left = 1, right = 0, top = min model.inset 1, bottom = 0 }
                        , Ui.behindContent (GuildIcon.columnBorderView model.inset)
                        ]
                        [ Ui.el [ Ui.padding 12, Ui.Font.bold ] (Ui.text "Prototype guild")
                        , Ui.el [ Ui.padding 12 ] (Ui.text "# general")
                        , Ui.el [ Ui.padding 12 ] (Ui.text "# another-channel")
                        ]
                    )
                ]
            ]
        )


control : String -> Msg -> String -> Ui.Element Msg
control id msg label =
    MyUi.elButton (Dom.id id) msg [ Ui.padding 8, Ui.border 1, Ui.borderColor MyUi.border1, Ui.rounded 4 ] (Ui.text label)


guildButton : Model -> Int -> ( String, Maybe String ) -> Ui.Element Msg
guildButton model index ( name, icon ) =
    MyUi.elButton (Dom.id ("guild-" ++ String.fromInt index))
        (Select index)
        [ Ui.width (Ui.px 56) ]
        (GuildIcon.view
            (if index == model.selected then
                GuildIcon.IsSelected

             else
                GuildIcon.Normal GuildIcon.NoNotification
            )
            { name = GuildName.fromStringLossy name, icon = Maybe.map FileStatus.fileHash icon }
        )
