import os

# The exact names from your SQL inserts in order
store_3_names = [
    "maisha_76",
    "ascocarb_50",
    "sultox_800",
    "vegetable_seeds_easeed",
    "plant_growth_nutrition_products",
    "safarimax_wp",
    "riomax_76_wp",
    "masulphur_80_wg",
    "malax_72_wp",
    "gazed_80wp",
    "z_force",
    "indofil_m45",
    "safari_zeb_80_wp",
    "codahumus_pk",
    "sunlaw_seeds_cabbage_f1_hybrid",
    "cabbage_copenhagen_market",
    "carrot_nantes",
    "carrot_chantenay",
    "carrot_london_market",
    "carrot_improved",
    "cabbage_danish_ball_head",
]

folder = "C:\\Users\\timot\\Desktop\\agricultureApplication\\backend\\uploads\\store_3"

# Get all files sorted by name (screenshots sort by date taken = order taken)
all_files = sorted(os.listdir(folder))

print(f"Found {len(all_files)} files, have {len(store_3_names)} names")
print("─" * 40)

if len(all_files) != len(store_3_names):
    print("⚠️  WARNING: file count doesn't match name count!")
    print("Files found:")
    for f in all_files:
        print(f"  {f}")
else:
    # Preview what will happen before actually renaming
    for old, new_name in zip(all_files, store_3_names):
        extension = old.split(".")[-1]
        new = f"{new_name}.{extension}"
        print(f"  {old}  →  {new}")

    confirm = input("\nLooks correct? Type 'yes' to rename: ")
    if confirm.strip().lower() == "yes":
        for old, new_name in zip(all_files, store_3_names):
            extension = old.split(".")[-1]
            new = f"{new_name}.{extension}"
            os.rename(
                os.path.join(folder, old),
                os.path.join(folder, new)
            )
            print(f"✅ Renamed: {old} → {new}")
        print("\nDone! All files renamed.")
    else:
        print("Cancelled. Nothing was renamed.")