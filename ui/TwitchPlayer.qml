import QtMultimedia 5.12
import QtQuick.Layouts 1.4
import QtQuick 2.9
import QtQuick.Controls 2.12 as Controls
import QtQuick.Window 2.3 as Window
import org.kde.kirigami 2.10 as Kirigami
import QtGraphicalEffects 1.0

import Mycroft 1.0 as Mycroft

import "." as Local

Mycroft.Delegate {
    id: twitchVideoPlayer

    property var videoSource: sessionData.video
    property var videoStatus: sessionData.status
    property var videoThumb: sessionData.videoThumb
    property var videoTitle: sessionData.setTitle
    property var videoAuthor: sessionData.videoAuthor
    property var videoViewCount: sessionData.viewCount
    property var videoPublishDate: sessionData.publishedDate
    property var videoListModel: sessionData.videoListBlob.videoList
    property var currentState: player.playbackState
    
    onCurrentStateChanged: {
        if(player.playbackState === MediaPlayer.PlayingState) {
            triggerGuiEvent("twitchstreams.aiix.playerStatus", {"player": "Playing"})
        } else if (player.playbackState === MediaPlayer.PausedState) {
            triggerGuiEvent("twitchstreams.aiix.playerStatus", {"player": "Paused"})
        } else if (player.playbackState === MediaPlayer.StoppedState) {
            triggerGuiEvent("twitchstreams.aiix.playerStatus", {"player": "Stopped"})
        }
    }

    fillWidth: true
    background: Rectangle {
        color: "black"
    }
    leftPadding: 0
    topPadding: 0
    rightPadding: 0
    bottomPadding: 0
    
    Keys.onReturnPressed: {
        player.playbackState === MediaPlayer.PlayingState ? player.pause() : player.play();
        controlBarItem.opened = true
    }
    
    Keys.onDownPressed: {
        controlBarItem.opened = true
        controlBarItem.forceActiveFocus()
    }
    
    function backToStreams(){
        parent.parent.parent.currentIndex--
        parent.parent.parent.currentItem.contentItem.forceActiveFocus()
        triggerGuiEvent("twitchstreams.aiix.playerRemoveActive", {})
    }
    
    onVideoTitleChanged: {
        if(videoTitle != ""){
            infomationBar.visible = true
        }
    }
    
    onFocusChanged: {
        if(focus) {
            player.forceActiveFocus();
        }
    }
    
    Connections {
        target: Window.window
        onVisibleChanged: {
            if(player.playbackState == MediaPlayer.PlayingState) {
                player.stop()
            }
        }
    }
    
    
    Timer {
        id: delaytimer
    }

    function delay(delayTime, cb) {
            delaytimer.interval = delayTime;
            delaytimer.repeat = false;
            delaytimer.triggered.connect(cb);
            delaytimer.start();
    }
    
    controlBar: Local.SeekControl {
        id: seekControl
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        title: videoTitle
        playerControl: player
        quality: sessionData.quality
        z: 1000
    }
    
    Item {
        id: videoRoot
        anchors.fill: parent 
            
         Rectangle { 
            id: infomationBar 
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            visible: false
            color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.6)
            implicitHeight: vidTitle.implicitHeight + Kirigami.Units.largeSpacing * 2
            z: 1001
            
            onVisibleChanged: {
                delay(15000, function() {
                    infomationBar.visible = false;
                })
            }
            
            Controls.Label {
                id: vidTitle
                visible: true
                maximumLineCount: 2
                wrapMode: Text.Wrap
                anchors.left: parent.left
                anchors.leftMargin: Kirigami.Units.largeSpacing
                anchors.verticalCenter: parent.verticalCenter
                text: videoTitle
                z: 100
            }
         }
            
        Image {
            id: thumbart
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            source: "images/twitch-logo.jpg"
            enabled: twitchVideoPlayer.videoStatus == "stop" ? 1 : 0
            visible: twitchVideoPlayer.videoStatus == "stop" ? 1 : 0
        }
        
        Video {
            id: player
            autoPlay: true
            autoLoad: true
            fillMode: VideoOutput.PreserveAspectFit
            anchors.fill: parent
            source: videoSource
            readonly property string currentStatus: twitchVideoPlayer.enabled ? twitchVideoPlayer.videoStatus : "pause"
            
            onStatusChanged: {
                console.log(status)
            }
            
            Keys.onDownPressed: {
                controlBarItem.opened = true
                controlBarItem.forceActiveFocus()
            }
        }
    }
}
