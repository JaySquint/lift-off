# **[Lift Off]**
One line: what this is and who it's for (hint: it's for you).

**Author:** [Jhonny Reyes] · **Course:** CMP 464/343 Product 1 · **Last updated:** [10/26/26]

## **1. About Me (the User)**
*Who am I in the context of this problem? What roles am I playing (student, employee, parent, athlete, gamer…)?*

[Athlete]

**The last 3 times this happened:** *Real, recent moments. For each: when and where, what went wrong, what it cost, what you did.*

1. I want to go to the gym at least 4 times a week, but I usually only go 2 times and sometimes not at all.

2. When my gym partner can’t go, I don’t feel like going by myself, and I end up skipping.

3. I’m working and in school full time, so I choose work because it feels productive and immediate, even though I know I’m losing out on my fitness goals.

**What it costs me:** *Be specific. How often, how much?*

- ⏱️ Time: It costs me time that I intended to spend on fitness or at the gym.

- 💸 Money: It costs me money, because I am paying a gym membership that I am not putting to good use.

- 🔋 Energy: I'm stuck in a cycle where I feel guilty about skipping, so I compensate by working harder, which makes me more tired, which makes the gym feel even less appealing next time.

- 🙂 Joy: I feel disappointed in myself for not being productive in this area of my life.

## **2. Problem Statement**
**Gut check:**

I need **[to** **stop cancelling going to the gym]** because **[I want to be healthier and** **fit]**.

**Five Whys:**

1. Why? Because I'm too tired.

2. Why? Because I work and go to school full time.

3. Why? Because I do not have the time and energy.

4. Why? Because I need to be healthy and fit.

5. Why? Because I want to live a longer life, and feel better physically and mentally.

**Problem statement:**

When I’ve already worked a shift and finished class in the afternoon, I struggle to follow through with going to the gym when I’m already tired and depleted. This happens about 3 days per week, and I end up canceling instead of working out. This costs me guilt, because I feel like I’m not disciplined or consistent enough, and that makes me feel like I’m falling behind on my goals. This happens because I’m already stretched thin by work and school, and I don’t have enough time or energy left to overcome the friction of going to the gym. Right now I stay home or go back to work instead, but that feels easier in the moment and only leaves me feeling worse later because it keeps me inconsistent. 

I’ll know this is solved when I can go to the gym 4 times a week for 3 months, including after work and class, and feel like I’m moving toward my health goals.

*Check: none of these words appear: app, website, platform, dashboard, tool, AI, track, automate, notify, feature.*

## **3. Existing Solutions**


| **What I use or tried** | **What it does well** | **Why it falls short** ***for me*** |
| :---: | :---: | :---: |
| Gym partner/friend commitment | Accountability | Failed because schedules didn’t line up |
| Music during workouts | It helps make the experience better when already there. | Not enough to motivate going. |
|  |  |  |
**The gap:** *In one sentence, what's still missing for me?*

[No tool or workaround that reduces the decision fatigue after work + class, no structure that works when my energy is already low, and no support that preserves consistency when my schedule is inconsistent.]

## **4. Features & Benefits**
*Every feature should move me toward my "solved when" line.*

| **Feature (what it does)** | **Benefit (how my life gets better)** | **MVP or Later?** |
| :---: | :---: | :---: |
| Feature 1 — A schedule system (set a time/date for the gym and things you must do) | This gives more of an official commitment, because it is scheduled, and on a list of things to do. It would move me toward my goal because it would make the gym feel more organized and less like a spur of the moment thing. | MVP |
| Feature 2 — Motivational reminder/notification when the scheduled time for a workout is coming | It would be motivation to go to the gym and progress in my goals. It would give me a push, even if small. This would move me towards the outcomes I described because it would motivate me to go to the gym and reach my goals. | MVP |
| Feature 3 — A system that says what days you worked out vs what days you did not (visual calendar of attendance) | This would give me a visual look at how consistent I am in the week/month. It would hold me accountable if I am slacking, and would make me feel good if I am consistent. This is more like accountability and motivation, rather than helping with the immediate decision to go. | Later |
| Feature 4 — A system where you can log workouts and track your progression | This would give me a visual look at my progress and progression in weight, as well as motivation to keep going. This would help me stay consistent because as I see progression, I will want to keep going.  | Later |
| Feature 5 — Sync and connection to health and fitness apps | This would help with tracking across applications and viewing progress, as well as sharing with friends. This would help keep me motivated, which can help with consistency. This does not affect the immediate decision to go as much. | Later |
## **MVP (2–3 features):** ***The skateboard: the smallest version*** ***I'd*** ***actually use.***
- Schedule system: one workout slot per day

- Reminder: a watch notification 30 minutes before the scheduled workout

## **Later:**
## **Not doing:** ***Things I'm deliberately leaving out.***
- A system that says what days you worked out vs what days you did not (visual calendar of attendance)

- A system where you can log workouts and track your progression

- Sync and connection to health and fitness apps

## **5. Tech Stack**
### **Front end**
- **Surface:** [Mobile]

- **Tools:** [Flutter]

- **Why:** *How does this fit where and when I have the problem?* **

  - My failure point isn’t “I forgot to plan” in general sense. It’s that after work + class, when I’m depleted, I need a prompt that cuts through the friction.

  - A mobile app lets me schedule a workout and deliver a reminder at the exact moment I’m most likely to bail.

  - It’s a better match than a CLI or browser app because it’s built for daily, in-the-moment nudges, not for occasional planning.
### **Back end**


| **Piece** | **Choice** | **Why** |
| :---: | :---: | :---: |
| Server / API | Firebase backend services | Fastest way to get a backend for a small app without building my own API server. |
| Data storage | Firestore | Simple database for scheduling and tracking workout slots/status. |
| Outside services (optional) | iOS local notifications | Schedules the reminder 30 minutes before a workout. Firebase Cloud Messaging is not needed for a reminder scheduled on my iPhone. |
| Hosting / deploy | None for MVP | Not required for a personal mobile app at first; hosting is optional unless I add a web view later. |
### **Architecture sketch**
flowchart LR

    U[User] --> A[Flutter App]

    A --> B[Firebase SDK]

    B --> C[(Firestore: planned workout times)]

    A --> D[iOS local notifications]

    D --> U  

## **6. Open Questions**
*What am I still unsure about? What do I need to figure out or test first?*

- Can I reliably receive the iPhone’s scheduled notification on my Apple Watch in the way I expect?

- What Flutter notification package and iOS permissions will I use to schedule local notifications?

- Do I need Firestore in the first version, or would local storage be enough for the planned workout times?

- If I use Firestore, what is the simplest appropriate way to secure my personal data?