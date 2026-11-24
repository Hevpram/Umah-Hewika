module com.umahhewika {
    requires javafx.controls;
    requires javafx.fxml;
    requires java.sql;

    opens com.umahhewika to javafx.fxml;
    exports com.umahhewika;
}