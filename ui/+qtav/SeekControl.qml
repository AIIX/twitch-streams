import QtMultimedia 5.12
import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.12 as Controls
import org.kde.kirigami 2.10 as Kirigami
import QtQuick.Templates 2.2 as Templates
import QtGraphicalEffects 1.0

import Mycroft 1.0 as Mycroft

Item {
    id: seekControl
    property bool opened: false
    property int duration: 0
    property int playPosition: 0
    property int seekPosition: 0
    property bool enabled: true
    property bool seeking: false
    property var playerControl
    property string title
    property alias quality: qualityLabel.text
    
    clip: true
    implicitWidth: parent.width
    implicitHeight: parent.width > 600 ? Kirigami.Units.iconSizes.huge + Kirigami.Units.largeSpacing * 2 : Kirigami.Units.iconSizes.large + Kirigami.Units.largeSpacing * 2
    opacity: opened

    Behavior on opacity {
        OpacityAnimator {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutCubic
        }
    }

    onOpenedChanged: {
        if (opened) {
            hideTimer.restart();
        }
    }
    
    onFocusChanged: {
        if(focus) {
            backButton.forceActiveFocus()
        }
    }

    Timer {
        id: hideTimer
        interval: 5000
        onTriggered: { 
            seekControl.opened = false;
            twitchVideoPlayer.forceActiveFocus();
        }
    }
    
    Rectangle {
        width: parent.width
        height: parent.height
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.8)
        //color: "white"
        y: opened ? 0 : parent.height

        Behavior on y {
            YAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
        
        Item {
            id: mainLayout
            anchors.fill: parent
            
            Controls.RoundButton {
                id: backButton                        
                width: parent.width > 600 ? Kirigami.Units.iconSizes.large : Kirigami.Units.iconSizes.medium
                height: width
                anchors.right: playButton.left
                anchors.rightMargin: Kirigami.Units.largeSpacing
                anchors.verticalCenter: parent.verticalCenter
                highlighted: focus ? 1 : 0
                icon.name: "go-previous-symbolic"
                z: 1000
                onClicked: {
                    backToStreams();
                    player.stop();
                }
                KeyNavigation.up: twitchVideoPlayer
                KeyNavigation.right: playButton
                Keys.onReturnPressed: {
                    clicked()
                }
                onFocusChanged: {
                    hideTimer.restart();
                }
            }
            
            Controls.RoundButton {
                id: playButton
                width: parent.width > 600 ? Kirigami.Units.iconSizes.large : Kirigami.Units.iconSizes.medium
                height: width
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
                highlighted: focus ? 1 : 0
                icon.name: playerControl.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                z: 1000
                onClicked: {
                    player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play();
                    hideTimer.restart();
                }
                KeyNavigation.up: twitchVideoPlayer
                KeyNavigation.left: backButton
                Keys.onReturnPressed: {
                    player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play();
                    hideTimer.restart();
                }
                onFocusChanged: {
                    hideTimer.restart();
                }
            }
            
            Controls.Label {
                id: qualityLabel
                width: parent.width > 600 ? Kirigami.Units.iconSizes.large : Kirigami.Units.iconSizes.medium
                height: parent.height
                anchors.left: playButton.right
                anchors.leftMargin: Kirigami.Units.largeSpacing
                verticalAlignment: Text.AlignVCenter
                color: Kirigami.Theme.linkColor
                font.capitalization: Font.AllUppercase
            }
        }
    }
}
