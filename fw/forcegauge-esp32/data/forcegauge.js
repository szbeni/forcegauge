class forceGauge {

    constructor(name, address) {
        this.name = name;
        this.address = address;
        this.ws = null;
        this.connected = false;
        this.onMessage = null;
        this.wsTimeout = null;
        this.debug = false;
        this.scale = 1;
        this.offset = 0;
        this.lastData = null;
        this.lastRawArray = [];
        this.tabatas = [];
        this.avgNum = 50;
        this.CONNECTION_TIMEOUT = 1000;
        this.RECONNECT_TIME = 1000;
    }
    getRawAverage() {
        var avg = 0;
        if (this.lastRawArray.length > 0) {
            var sum = this.lastRawArray.reduce((a, b) => a + b)
            avg = sum / this.lastRawArray.length;
        }
        return avg;
    }

    setOffset(v) {
        if (v === undefined) {
            v = this.getRawAverage();
        }
        this.sendMessage("offset:" + v);
    }

    setScale(v) {
        this.sendMessage("scale:" + v);
    }

    setTime(v) {
        this.sendMessage("time:" + v);
    }

    removeTabata(id) {
        this.sendMessage("del_tabata:" + id);
    }

    removeTabatas() {
        this.sendMessage("del_tabatas:");
    }

    addTabata(tabata) {
        this.sendMessage("add_tabata:" + tabata);
    }

    _getTabata(id) {
        this.sendMessage("get_tabata:" + id);
    }

    getTabatas() {
        this.tabatas = []
        this._getTabata(0);
    }

    sendMessage(msg) {
        if (this.connected) {
            this.ws.send(msg);
        }
    }

    debugLog(msg) {
        var v = "[ForceGaugeDevice][" + this.name + "]: " + String(msg);
        console.log(v);
    }

    reconnect() {
        var _this = this;
        _this.debugLog("Reconnect");
        if (_this.ws != null) {

            _this.ws.onmessage = null;
            _this.ws.onopen = null;
            _this.ws.onclose = null;
            _this.ws.onerror = null;
            _this.ws.close();
            _this.ws = null;
            _this.connected = false;
            setTimeout(function () {
                _this.connect();
            }, _this.RECONNECT_TIME);

        }
    }
    disconnect() {
        if (_this.ws != null) {
            _this.ws.onclose = null;
            _this.ws.close();
            _this.ws = null;
        }
    }
    connect() {
        var _this = this;
        if (_this.ws == null) {
            var resetSocketTimeout = function () {
                if (_this.wsTimeout) {
                    clearTimeout(_this.wsTimeout);
                }
                _this.wsTimeout = setTimeout(function () {
                    _this.debugLog("Timeout");
                    _this.reconnect();

                }, _this.CONNECTION_TIMEOUT);
            }

            _this.ws = new WebSocket(_this.address);

            _this.ws.onopen = function () {
                _this.connected = true;
                _this.debugLog("Connection opened");
                resetSocketTimeout();
                if (_this.onConnected) {
                    _this.onConnected();
                }
            };

            _this.ws.onmessage = function (evt) {
                try {
                    var msg = JSON.parse(evt.data);
                    resetSocketTimeout();
                    if ("scale" in msg) {
                        _this.scale = parseFloat(msg["scale"])
                        _this.debugLog("Scale: " + _this.scale);
                    }
                    if ("offset" in msg) {
                        _this.offset = parseInt(msg["offset"])
                        _this.debugLog("Offset: " + _this.offset);
                    }
                    if ("tabata" in msg) {
                        var tabata = msg["tabata"];
                        var id = msg["id"];
                        if (Object.keys(tabata).length === 0) {
                            if (_this.onTabatas) {
                                _this.onTabatas(_this.tabatas);
                            }
                        }
                        else {
                            _this.tabatas.push(tabata)
                            _this._getTabata(id + 1);
                        }
                    }
                    if ("data" in msg) {
                        var data = msg["data"];
                        _this.lastData = data[data.length - 1];
                        _this.lastRawArray.push(Number(_this.lastData['raw']));
                        while (_this.lastRawArray.length > _this.avgNum) {
                            _this.lastRawArray.shift();
                        }
                        if (_this.onNewData) {
                            _this.onNewData(data);
                        }
                    }
                }
                catch (err) {
                    _this.debugLog("Error receving data: " + err);
                }
            };

            _this.ws.onclose = function () {
                _this.debugLog("Connection closed");
                _this.reconnect();
            };

            _this.ws.onerror = function (err) {
                _this.debugLog("Connection Error: " + err);
            };

        }
    }
}