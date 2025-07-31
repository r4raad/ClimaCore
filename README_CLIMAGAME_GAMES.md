# ClimaGame: Adding New Games

This guide explains how to add new games to the ClimaGame system. All game data must be managed in Firestore—**never hardcoded in the app**. This ensures flexibility, scalability, and easy updates.

---

## 1. Firestore Structure

### **A. Collections Overview**
- `games/` — Stores game configurations (each game is a document)
- `schools/` — Each school has a subcollection for game stats
- `missions/` — All available missions
- `ecores/` — All ecore locations and their missions

### **B. Example Structure**
```
games/{gameId}
  - startDate: Timestamp
  - endDate: Timestamp
  - type: 'school' | 'individual' | ...
  - title: string
  - description: string
  - isActive: boolean
  - ... (other config fields)

schools/{schoolId}/gameStats/{gameId}
  - points: number
  - completedMissions: array
  - ...

missions/{missionId}
  - title: string
  - description: string
  - points: number
  - ...

ecores/{ecoreId}
  - name: string
  - latitude: number
  - longitude: number
  - missions: array of missionIds
  - ...
```

---

## 2. Steps to Add a New Game

1. **Create a new document in `games/`**
   - Set `startDate`, `endDate`, `type`, `title`, `description`, and any other configs.
   - Set `isActive: true` for the current game.

2. **Add or update missions in `missions/`**
   - Each mission should have a unique `missionId`.
   - Include all necessary fields (title, description, points, etc.).

3. **Add or update ecores in `ecores/`**
   - Each ecore should reference its missions by `missionId`.
   - Set location fields (`latitude`, `longitude`).

4. **For each school, initialize or update `gameStats`**
   - Create a document for the new game under `schools/{schoolId}/gameStats/{gameId}`.
   - Initialize `points` and other stats as needed.

5. **(Optional) Add any new config fields needed for your game**
   - The app will fetch and use any new fields you add, as long as you update the UI logic accordingly.

---

## 3. Best Practices

- **Never hardcode game data in the app.**
- **Use Firestore for all game configuration and data.**
- **Keep game logic flexible** by using config fields in the `games` collection.
- **To add new game types or rules,** add new fields to the game document and update the app logic if needed.
- **Deactivate old games** by setting `isActive: false` when a new game starts.

---

## 4. Example: Creating a New 2-Month School Game

1. Add a new document to `games/`:
   - `startDate`: 2024-07-01
   - `endDate`: 2024-08-31
   - `type`: 'school'
   - `title`: 'Summer Eco Challenge'
   - `description`: 'Compete as schools to complete eco missions!'
   - `isActive`: true

2. Add missions and ecores as needed.
3. Initialize `gameStats` for each school.

---

## 5. Google Maps API Key

- The app requires a Google Maps API key for map features. Add your key in the designated place in the code when ready.

---

## 6. Need Help?

If you have questions or want to add new game logic, update the UI, or automate Firestore setup, contact the development team or refer to the code comments for guidance.