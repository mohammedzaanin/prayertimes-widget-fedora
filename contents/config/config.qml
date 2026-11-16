import QtQuick
import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: String(Qt.locale().name).toLowerCase().indexOf("ar") === 0 ? "عام" : "General"
        icon: "configure"
        source: "configGeneral.qml"
    }
}
