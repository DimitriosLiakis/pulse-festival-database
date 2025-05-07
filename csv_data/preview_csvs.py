import os

# List all CSV files in the current directory
csv_files = [f for f in os.listdir('.') if f.endswith('.csv')]

for file_name in csv_files:
    print(f"\n--- First 3 lines of {file_name} ---")
    try:
        with open(file_name, 'r', encoding='utf-8') as file:
            for i in range(3):
                line = file.readline()
                if not line:
                    break
                print(line.strip())
    except Exception as e:
        print(f"Error reading {file_name}: {e}")
