import requests
import json

get_all_makes_url = "https://vpic.nhtsa.dot.gov/api/vehicles/GetAllMakes?format=json"
get_vehicle_types_url = "https://vpic.nhtsa.dot.gov/api/vehicles/GetVehicleTypesForMake/{}?format=json"

# Fetch all makes
response = requests.get(get_all_makes_url)
if response.status_code == 200:
    makes_data = response.json()
    makes = makes_data.get("Results", [])

    # Dictionary to store vehicle types
    vehicle_types = set()

    # Fetch vehicle types for each make
    for make in makes:
        make_name = make.get("Make_Name")
        if make_name:
            response = requests.get(get_vehicle_types_url.format(make_name))
            if response.status_code == 200:
                types_data = response.json()
                for vehicle_type in types_data.get("Results", []):
                    vehicle_types.add(vehicle_type.get("VehicleTypeName"))

    # Save as JSON
    vehicle_types_list = list(vehicle_types)
    with open("vehicle_types.json", "w") as f:
        json.dump(vehicle_types_list, f, indent=4)

    print("Vehicle types saved to vehicle_types.json")
else:
    print("Failed to fetch makes.")
