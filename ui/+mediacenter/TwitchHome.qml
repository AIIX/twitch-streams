/*
 *  Copyright 2018 by Aditya Mehra <aix.m@outlook.com>
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.9
import QtQuick.Layouts 1.4
import QtGraphicalEffects 1.0
import QtQuick.Controls 2.3
import org.kde.kirigami 2.8 as Kirigami
import Mycroft 1.0 as Mycroft
import "views" as Views
import "delegates" as Delegates

Mycroft.Delegate {
    id: delegate
    property bool busyIndicate: false
    
    fillWidth: true
    
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    skillBackgroundSource: Qt.resolvedUrl("images/twitch-background.png")
        
    Connections {
        target: Mycroft.MycroftController
        onIntentRecevied: {
            if(type == "speak") {
                busyIndicatorPop.close()
                busyIndicate = false
            }
        }
    }
    
    onFocusChanged: {
        busyIndicatorPop.close()
        busyIndicate = false
        if(delegate.focus){
            console.log("focus is here")
        }
    }
    
    Keys.onBackPressed: {
        parent.parent.parent.currentIndex++
        parent.parent.parent.currentItem.contentItem.forceActiveFocus()
    }
    
    contentItem: ColumnLayout {
        id: colLay1
        
        Rectangle {
            color: Qt.rgba(0, 0, 0, 0.8)
            Layout.fillWidth: true
            Layout.preferredHeight: Kirigami.Units.gridUnit * 3 
            Layout.maximumHeight: Kirigami.Units.gridUnit * 4
            z: 100
            
            Image {
                height: parent.height - Kirigami.Units.largeSpacing
                width: height + Kirigami.Units.gridUnit * 5
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: Kirigami.Units.largeSpacing
                source: "images/twitch-logo-small.png"
            }
            
            Button {
                id: goToVidButton
                height: parent.height - Kirigami.Units.largeSpacing
                width: height
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: Kirigami.Units.largeSpacing
                visible: sessionData.showPlayerButton
                
                background: Rectangle {
                    color: goToVidButton.activeFocus ? Kirigami.Theme.backgroundColor : Kirigami.Theme.highlightColor
                }
                
                contentItem: Item {
                    Image {
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.medium
                        height: Kirigami.Units.iconSizes.medium
                        source: "images/forward.png"
                    }
                }
                
                onClicked: {
                    parent.parent.parent.currentIndex++
                    parent.parent.parent.currentItem.contentItem.forceActiveFocus()
                }
                
                Keys.onReturnPressed: {
                    clicked()
                }
            }
        }
        
        TwitchHomeView {
            id: homeCatView
            Layout.fillWidth: true
            Layout.fillHeight: true
            KeyNavigation.up: goToVidButton.visible ? goToVidButton : homeCatView
        }
    }
    
    Popup {
        id: busyIndicatorPop
        width: parent.width
        height: parent.height
        background: Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.5)
        }
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent
        
        BusyIndicator {
            running: busyIndicate
            anchors.centerIn: parent
        }
        
        onOpened: {
            busyIndicate = true
        }
        
        onClosed: {
            busyIndicate = false
        }
    }
} 
