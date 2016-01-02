#!/usr/bin/env python
import appindicator
import gtk
import os
import signal
import sys

START_LABEL = "Start shairport"
STOP_LABEL = "Stop shairport"

class ShairplayIndicator:
    def __init__(self):
        self.indicator = appindicator.Indicator(
                            "shairport-indicator",
                            "multimedia-player-apple-ipod-touch",
                            appindicator.CATEGORY_APPLICATION_STATUS)

        self.indicator.set_status(appindicator.STATUS_ACTIVE)
        self.menu_setup()
        self.indicator.set_menu(self.menu)
        self.cpid = 0
        self.shairport_argv = []

    def menu_setup(self):
        self.menu = gtk.Menu()

        self.menu_ctrl = gtk.MenuItem(START_LABEL)
        self.menu_ctrl.connect("activate", self.ctrl)
        self.menu_ctrl.show()
        self.menu.append(self.menu_ctrl)

        self.quit_item = gtk.MenuItem("Quit")
        self.quit_item.connect("activate", self.quit)
        self.quit_item.show()
        self.menu.append(self.quit_item)

    def check_child(self):
        gtk.timeout_add(1000, indicator.check_child)
        if self.cpid == 0:
            self.menu_ctrl.set_label(START_LABEL)
        else:
            self.menu_ctrl.set_label(STOP_LABEL)

    def ctrl(self, widget):
        if self.menu_ctrl.get_label() == START_LABEL:
            self.start()
        else:
            self.stop()

    def start(self):
        self.stop();
        self.cpid = os.fork()
        if not self.cpid:
            os.execvp("shairport", self.shairport_argv)
            os._exit(0)

    def stop(self):
        if self.cpid:
            os.kill(self.cpid, signal.SIGINT)
            os.waitpid(self.cpid, 0)
            self.cpid = 0

    def quit(self, widget):
        self.stop()
        sys.exit(0)

if __name__ == "__main__":
    indicator = ShairplayIndicator()
    indicator.shairport_argv = sys.argv[:]
    indicator.shairport_argv[0] = "shairport"
    indicator.start()
    gtk.timeout_add(1000, indicator.check_child)
    gtk.main()
