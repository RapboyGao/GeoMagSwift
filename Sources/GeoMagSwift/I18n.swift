import Foundation

internal enum I18n {
    private static func string(_ key: String, _ fallback: String) -> String {
        Bundle.module.localizedString(forKey: key, value: fallback, table: nil)
    }

    static let magneticFieldSolutionTitle = string("magnetic_field_solution_title", "Magnetic Field Solution")
    static let mainFieldTitle = string("magnetic_field_solution_main_field", "Main Field")
    static let secularVariationTitle = string("magnetic_field_solution_secular_variation", "Secular Variation")

    static let north = string("magnetic_field_solution_north", "North")
    static let east = string("magnetic_field_solution_east", "East")
    static let down = string("magnetic_field_solution_down", "Down")
    static let horizontalIntensity = string("magnetic_field_solution_horizontal_intensity", "Horizontal Intensity")
    static let totalIntensity = string("magnetic_field_solution_total_intensity", "Total Intensity")
    static let declination = string("magnetic_field_solution_declination", "Declination")
    static let inclination = string("magnetic_field_solution_inclination", "Inclination")

    static let unitNT = string("magnetic_field_solution_unit_nt", "nT")
    static let unitNTPerYear = string("magnetic_field_solution_unit_nt_per_year", "nT/year")
    static let unitDegree = string("magnetic_field_solution_unit_degree", "°")
    static let unitArcMinPerYear = string("magnetic_field_solution_unit_arcmin_per_year", "arcmin/year")

    static let mapTitle = string("geomagnetic_map_title", "Geomagnetic Field Map")
    static let mapLongPressInstruction = string(
        "geomagnetic_map_long_press_instruction", "Long press the map to select a location")
    static let mapModel = string("geomagnetic_map_model", "Model")
    static let mapDate = string("geomagnetic_map_date", "Date")
    static let mapAltitude = string("geomagnetic_map_altitude", "Altitude")
    static let mapSelectedLocation = string("geomagnetic_map_selected_location", "Selected Location")
    static let mapMainField = string("geomagnetic_map_main_field", "Main Field")
    static let mapSecularVariation = string("geomagnetic_map_secular_variation", "Secular Variation")
    static let mapLatitude = string("geomagnetic_map_latitude", "Latitude")
    static let mapLongitude = string("geomagnetic_map_longitude", "Longitude")
    static let mapCalculationError = string("geomagnetic_map_calculation_error", "Calculation Error")
    static let mapInvalidAltitude = string(
        "geomagnetic_map_error_invalid_altitude", "Altitude must be a finite value.")
    static let mapInvalidInput = string("geomagnetic_map_error_invalid_input", "Invalid input: %@.")
    static let mapInvalidOutput = string(
        "geomagnetic_map_error_invalid_output", "Calculation produced an invalid %@ value.")
    static let mapInvalidModelDegree = string(
        "geomagnetic_map_error_invalid_model_degree", "Invalid model degree %d; maximum is %d.")
    static let mapInvalidCoefficientIndex = string(
        "geomagnetic_map_error_invalid_coefficient_index", "Invalid coefficient index (n=%d, m=%d).")
    static let mapInvalidCoefficientValues = string(
        "geomagnetic_map_error_invalid_coefficient_values", "Invalid coefficient values (n=%d, m=%d).")
    static let mapInvalidValidityRange = string(
        "geomagnetic_map_error_invalid_validity_range", "The selected model has an invalid validity range.")
    static let mapInvalidEpochs = string(
        "geomagnetic_map_error_invalid_epochs", "The selected model has invalid epochs.")
    static let mapNoModelForYear = string(
        "geomagnetic_map_error_no_model_for_year", "No model is available for year %.2f.")
    static let mapDateRange = string(
        "geomagnetic_map_error_date_range", "Date must be between %.2f and %.2f.")

    static func formatted(_ format: String, _ arguments: CVarArg...) -> String {
        String(format: format, locale: Locale.current, arguments: arguments)
    }
}
