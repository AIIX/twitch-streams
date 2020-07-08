# -*- coding: utf-8 -*-

import timeago, datetime
import dateutil.parser
from os.path import dirname
import streamlink
from mycroft.skills.core import MycroftSkill, intent_file_handler
from mycroft.messagebus.message import Message
from mycroft.util.log import LOG
from twitch import TwitchHelix

__author__ = 'aix'


class TwitchStreams(MycroftSkill):
    def __init__(self):
        super(TwitchStreams, self).__init__(name="TwitchStreams")
        self.streamObject = {}
        self.streamList = []
        self.set_refresh_token_url = "https://twitchtokengenerator.com/api/refresh" \
                                     "/mvfohzdugl5spyqmzsilbfoqm4d45ie965i6h55vxeovbr3eqe "
        self.client = TwitchHelix(client_id="gp762nuuoqcoxypju8c569th9wz7q5",
                                  oauth_token="fu4l5bwwgmk9b4f7rfaphzetntp30o")

    def initialize(self):
        self.load_data_files(dirname(__file__))

        self.bus.on('twitch-streams.aiix.home', self.launcher_id)
        self.gui.register_handler('twitchstreams.aiix.playstream',
                                  self.play_stream)
        self.gui.register_handler('twitchstreams.aiix.playerStatus', self.handle_player_states)
        self.gui.register_handler('twitchstreams.aiix.playerRemoveActive', self.handleRemoveActive)

    def handle_player_states(self, message):
        playerState = message.data['player']
        if playerState == "Playing":
            self.gui["showPlayerButton"] = True
        if playerState == "Paused":
            self.gui["showPlayerButton"] = True
        if playerState == "Stopped":
            self.gui["showPlayerButton"] = False
            
    def handleRemoveActive(self):
        self.gui.remove_page("TwitchPlayer.qml")

    def launcher_id(self, message):
        self.prepare_homepage({})

    @intent_file_handler('show_home_twitch.intent')
    def show_twitch_app_by_voice(self, message):
        self.prepare_homepage({})

    def prepare_homepage(self, message):
        self.gui.clear()
        self.enclosure.display_manager.remove_active()
        self.gui["loadingStatus"] = ""
        self.gui.show_page("TwitchLogo.qml", override_idle=True)
        self.prepare_streams_for_home()

    def prepare_streams_for_home(self):
        get_streams = self.client.get_streams();
        for i in range(len(get_streams)):
            stream_dict = {
                "id": str(get_streams[i].id),
                "user_id": str(get_streams[i].user_id),
                "user_name": str(get_streams[i].user_name),
                "game_id": str(get_streams[i].game_id),
                "type": get_streams[i].type,
                "title": str(get_streams[i].title),
                "viewer_count": str(get_streams[i].viewer_count),
                "started_at": self.build_start_time(get_streams[i].started_at.strftime('%Y-%m-%dT%H:%M:%SZ')),
                "language": str(get_streams[i].language),
                "thumbnail_url": str(get_streams[i].thumbnail_url).format(width=240, height=240),
                "tag_ids": list(get_streams[i].tag_ids)
            }
            self.streamList.append(stream_dict)
        self.streamObject['streams'] = self.streamList
        self.display_homepage();

    def display_homepage(self):
        self.gui.clear()
        self.enclosure.display_manager.remove_active()
        self.gui["showPlayerButton"] = False
        self.gui["liveStreamsModel"] = self.streamObject
        self.gui.show_page("TwitchHome.qml", override_idle=True)

    def play_stream(self, message):
        get_username = message.data['user_name']
        get_title = message.data['title']
        extract_stream_from_url = "https://www.twitch.tv/{0}".format(get_username)
        get_playable_link = self.process_video_stream(extract_stream_from_url)
        if get_playable_link:
            self.gui["video"] = str(get_playable_link[0])
            self.gui["quality"] = str(get_playable_link[1])
            self.gui["status"] = str("play")
            self.gui["setTitle"] = str(message.data['title'])
            self.gui["viewCount"] = str(message.data['viewer_count'])
            self.gui["publishedDate"] = str(message.data['started_at'])
            self.gui["videoAuthor"] = str(message.data['user_name'])
            self.gui.show_page("TwitchPlayer.qml", override_idle=True)

    def process_video_stream(self, videolink):
        try:
            streams = streamlink.streams(videolink)
            if "480p" in streams.keys():
                LOG.info("Playing 480p Stream")
                video_quality = "480p"
                video_url = streams["480p"].url
            elif "360p" in streams.keys():
                LOG.info("Playing 360p Stream")
                video_quality = "360p"
                video_url = streams["360p"].url
            elif "720p" in streams.keys():
                LOG.info("Playing 720p Stream")
                video_quality = "720p"
                video_url = streams["720p"].url
            else:
                LOG.info("Playing Best Stream")
                video_quality = "best"
                video_url = streams["best"].url
            
            streamInformation = [video_url, video_quality]
            return streamInformation

        except all as exception:
            return None

    def build_start_time(self, update):
        now = datetime.datetime.now() + datetime.timedelta(seconds = 60 * 3.4)
        date = dateutil.parser.parse(update)
        naive = date.replace(tzinfo=None)
        dtstring = timeago.format(naive, now)
        return dtstring

    def stop(self):
        self.enclosure.bus.emit(Message("metadata", {"type": "stop"}))
        pass

def create_skill():
    return TwitchStreams()
