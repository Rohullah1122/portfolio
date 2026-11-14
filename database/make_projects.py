# builds the projects part of seed.sql and update_v2.sql
import json

gh = "https://github.com/Rohullah1122/"

ALP = [
  dict(slug="portfolio-website", name="Portfolio Website", cat="web", status="Completed", year=2026,
    summary="This site: a full stack portfolio with an admin panel and an AI assistant.",
    tagline="React front end, Express API, PostgreSQL and a Claude-powered chat",
    desc="The portfolio you are looking at. Every project, skill and profile detail comes from a PostgreSQL database and is edited from a private admin panel, so nothing is hard-coded. Visitors can read full case studies with database diagrams, send a message, or ask the AI assistant questions that it answers only from the portfolio data.",
    github="", tags=["React","Node.js","Express","PostgreSQL","Tailwind"],
    stack=dict(languages=["JavaScript","SQL"],frameworks=["React","Express","Tailwind"],databases=["PostgreSQL"],tools=["VS Code","Vite","Git","pgAdmin"]),
    features=["Admin panel to manage projects, skills, profile, experience and messages","Case study pages with database diagrams, UML and screenshots","Contact form saved to the database, with read and unread messages","AI chat assistant that answers questions about me from my own data","Image and resume uploads, saved as files on the server","Sign-in with hashed passwords and JWT, plus rate limiting"],
    challenges=[("Letting an AI answer questions without making things up","The server builds the assistant's instructions from the database on each request and tells it to use only those facts. Without an API key it falls back to simple answers from the same data."),
                ("Keeping the admin safe","Passwords are hashed with bcrypt, every admin route checks a signed token, and login, chat and contact requests are rate limited.")],
    arch=("Client / REST API","React + Vite","Node.js + Express","PostgreSQL"),
    erd=[("projects",[("id","INT","pk"),("slug","VARCHAR(80)","uq"),("name","VARCHAR(150)",None),("status","VARCHAR(20)",None)]),
         ("project_tags",[("id","INT","pk"),("project_id","INT","fk"),("tag","VARCHAR(60)",None)]),
         ("messages",[("id","INT","pk"),("name","VARCHAR(120)",None),("email","VARCHAR(255)",None),("is_read","BOOLEAN",None)]),
         ("admins",[("id","INT","pk"),("email","VARCHAR(255)","uq"),("password_hash","VARCHAR(255)",None)])],
    rel=[("project_tags.project_id","projects.id")]),

  dict(slug="hussainis-restaurant", name="Hussaini's Restaurant", cat="web", status="Completed", year=2026,
    summary="Restaurant website: browse the menu, order for pickup or delivery, book a table and ask the AI assistant.",
    tagline="A full restaurant experience in React, from menu to admin dashboard",
    desc="A restaurant website built with React for a college final project (team of two). Customers search and filter the menu by category, diet and price, add items to a cart, order for pickup or delivery, follow their order status, book tables or events, and ask a chat assistant about specials and dietary options. Admins add, edit and remove menu items, update order status and confirm reservations. All data is kept in React state and saved to the browser, so it works without a backend.",
    github="https://github.com/Rohullah1122/Restaurant-System", live="https://frontend-lake-rho-45.vercel.app/", embed=True,
    icon="/seed/projects/hussainis-restaurant/icon.svg", hero="/seed/projects/hussainis-restaurant/home.webp",
    screens=["/seed/projects/hussainis-restaurant/home.webp","/seed/projects/hussainis-restaurant/menu.webp","/seed/projects/hussainis-restaurant/cart.webp","/seed/projects/hussainis-restaurant/reservation.webp","/seed/projects/hussainis-restaurant/ai_assistant.webp","/seed/projects/hussainis-restaurant/login.webp","/seed/projects/hussainis-restaurant/intro.webp"],
    uml=dict(desc="Use cases for customers and admins, and the order flow from adding to the cart to the admin updating the status.", usecase="/seed/projects/hussainis-restaurant/use_cases.webp", sequence="/seed/projects/hussainis-restaurant/order_flow.webp"),
    tags=["React","Vite","React Router"],
    stack=dict(languages=["JavaScript","CSS"],frameworks=["React 18","React Router 6","Vite"],databases=["Browser localStorage"],tools=["VS Code","Git","Vercel"]),
    features=["Menu search with category, diet and price filters","Cart with quantities, pickup or delivery","My Orders page with live status updates","Table and event reservations","Chat assistant with quick questions","Admin dashboard for menu, orders and reservations"],
    challenges=[("Sharing data between many pages without a backend","All shared data lives in App.jsx and is passed down as props; every change is saved to localStorage so nothing is lost on refresh."),
                ("Two people working on the same app","Each person owned different files, with a written task list, so merges never overwrote each other's work.")],
    arch=("Single-page app","React + React Router","None (Part 1 frontend)","Browser localStorage"),
    erd=[("menu_items",[("id","INT","pk"),("name","STRING",None),("category","STRING",None),("price","DECIMAL",None),("dietary","STRING[]",None),("available","BOOLEAN",None)]),
         ("orders",[("id","INT","pk"),("customer","STRING","fk"),("type","STRING",None),("address","STRING",None),("total","DECIMAL",None),("status","STRING",None)]),
         ("reservations",[("id","INT","pk"),("customer","STRING","fk"),("date","DATE",None),("time","STRING",None),("guests","INT",None),("status","STRING",None)]),
         ("accounts",[("email","STRING","pk"),("name","STRING",None),("role","STRING",None)])],
    rel=[("orders.customer","accounts.email"),("reservations.customer","accounts.email")]),

  dict(slug="rahmanis-junkyard", name="Rahmani's Junkyard", cat="web", status="Completed", year=2025,
    summary="Online storefront and admin system for a car salvage yard: inventory, sales, customers and suppliers.",
    tagline="Online storefront and admin system for a car salvage yard",
    desc="A full stack web app that brings a car junkyard online. Customers search vehicles by make and model, submit their own car for sale with four required photos, and contact the business. Staff use a secure admin panel to add vehicles and parts, record sales and payments, manage customers and suppliers, see sales and revenue charts, and reply to messages. Admins can reset their password by email.",
    github="https://github.com/Rohullah1122/Rahmani-s-Group",
    icon="/seed/projects/rahmanis-junkyard/icon.webp", hero="/seed/projects/rahmanis-junkyard/hero.webp",
    screens=["/seed/projects/rahmanis-junkyard/welcome_page.webp","/seed/projects/rahmanis-junkyard/inventory.webp","/seed/projects/rahmanis-junkyard/car_info.webp","/seed/projects/rahmanis-junkyard/sell_mycar.webp","/seed/projects/rahmanis-junkyard/adming_dashboard.webp","/seed/projects/rahmanis-junkyard/add_vehicale.webp","/seed/projects/rahmanis-junkyard/vehicle_inventory.webp","/seed/projects/rahmanis-junkyard/payments.webp","/seed/projects/rahmanis-junkyard/customers.webp","/seed/projects/rahmanis-junkyard/contact.webp"],
    tags=["React","Node.js","Express","SQL"],
    stack=dict(languages=["JavaScript","SQL"],frameworks=["React","Express"],databases=["SQL database"],tools=["VS Code","Git","Multer","Nodemailer","bcrypt","Passport"]),
    features=["Search vehicles by make and model, with photos","Sell My Car form that requires 4 photos","Admin dashboard with sales and purchase charts and total revenue","Add vehicles with supplier, parts, pricing and stock","Manage customers, suppliers and sales, with paid and pending payments","Password reset for admins by email"],
    challenges=[("Turning one car into many sellable parts","Each car is stored once, its parts reference it, and inventory tracks stock and status per part, so a single vehicle feeds many sales."),
                ("Keeping money records consistent","Every purchase and sale also writes a transaction row, so revenue charts and payment status always add up.")],
    arch=("Client / REST API","React","Node.js + Express","SQL database"),
    erd=[("suppliers",[("supplier_id","INT","pk"),("name","VARCHAR",None),("phone","VARCHAR",None),("email","VARCHAR",None)]),
         ("cars",[("car_id","INT","pk"),("supplier_id","INT","fk"),("vin_number","VARCHAR","uq"),("make","VARCHAR",None),("model","VARCHAR",None),("year","INT",None),("purchase_price","DECIMAL",None)]),
         ("parts",[("part_id","INT","pk"),("car_id","INT","fk"),("part_name","VARCHAR",None),("condition","VARCHAR",None),("selling_price","DECIMAL",None),("status","VARCHAR",None)]),
         ("inventory",[("inventory_id","INT","pk"),("part_id","INT","fk"),("quantity","INT",None),("status","VARCHAR",None)]),
         ("customers",[("customer_id","INT","pk"),("First_name","VARCHAR",None),("Last_name","VARCHAR",None),("email","VARCHAR",None),("phone","VARCHAR",None)]),
         ("sales",[("sale_id","INT","pk"),("customer_id","INT","fk"),("part_id","INT","fk"),("price_sold","DECIMAL",None),("Amount_paid","DECIMAL",None),("Amount_pending","DECIMAL",None),("status","VARCHAR",None)])],
    rel=[("cars.supplier_id","suppliers.supplier_id"),("parts.car_id","cars.car_id"),("inventory.part_id","parts.part_id"),("sales.customer_id","customers.customer_id"),("sales.part_id","parts.part_id")]),

  dict(slug="property-dealer", name="Property Dealer", cat="mobile", status="Completed", year=2021,
    summary="Android app for listing houses for rent and finding a place to live.",
    tagline="Owners post houses, renters browse, save and chat",
    desc="An Android app that connects house owners with people looking to rent. Owners sign in with their phone number and post a house with photos, rent, size and room details. Renters browse and search listings, save the ones they like, rate them and message the owner directly in the app.",
    github=gh+"property_dealer", tags=["Android (Java)","Firebase"],
    stack=dict(languages=["Java","XML"],frameworks=["Android SDK","Material Components"],databases=["Firebase Realtime Database","Firebase Storage"],tools=["Android Studio","Glide","Git"]),
    features=["Phone number sign-in with Firebase Authentication","Post a house with photos, rent, rooms, kitchens, washrooms, size and exact location","Browse and search all listings","Save houses to a personal list","In-app chat between renters and owners","Ratings and feedback on houses"],
    challenges=[("The same house could be saved twice","Before saving, the app checks the user's saves for that house id and shows a message if it is already there."),
                ("Loading many house photos smoothly","Photos are stored in Firebase Storage and loaded with Glide, using a placeholder while they download.")],
    arch=("Activities + Fragments","Android (Java, XML, ViewBinding)","Firebase Authentication","Firebase Realtime Database + Storage"),
    erd=[("Users",[("uid","STRING","pk"),("username","STRING",None),("phone","STRING",None),("userimg","STRING",None)]),
         ("houses",[("hid","STRING","pk"),("userid","STRING","fk"),("houseloc","STRING",None),("houserent","STRING",None),("numberofroom","STRING",None),("type","STRING",None),("houseimg","STRING",None)]),
         ("saves",[("uid","STRING","fk"),("hid","STRING","fk")])],
    rel=[("houses.userid","Users.uid"),("saves.uid","Users.uid"),("saves.hid","houses.hid")]),

  dict(slug="book-store", name="Book Store", cat="mobile", status="Completed", year=2022,
    summary="Android book shop with a customer app and an admin panel.",
    tagline="Browse and buy books, while the admin manages stock and sales",
    desc="An Android book store with two sides. Customers browse and search books, read the details, buy them and chat with the store. The admin side adds and updates books with cover images, prices and stock, and reviews sales, purchases and users. A later version added unread message counts.",
    github=gh+"Book_store", tags=["Android (Java)","Firebase"],
    stack=dict(languages=["Java","XML"],frameworks=["Android SDK","Material Components"],databases=["Firebase Realtime Database","Firebase Storage"],tools=["Android Studio","Glide","Git"]),
    features=["Separate customer and admin areas","Admin adds and updates books: cover, author, pages, price and quantity","Customers browse, search and open book details","Purchases recorded as sales the admin can review","Chat between customers and the store, with unread counts","Ratings and feedback"],
    challenges=[("One app for two kinds of users","Admin screens live in their own package and layout, and books store the id of the admin who added them.")],
    arch=("Activities + Fragments","Android (Java, XML, ViewBinding)","Firebase Authentication","Firebase Realtime Database + Storage"),
    erd=[("Users",[("uid","STRING","pk"),("username","STRING",None),("userimg","STRING",None)]),
         ("Book",[("Bookid","STRING","pk"),("Bookname","STRING",None),("Bookauthor","STRING",None),("bookprice","STRING",None),("bquantity","STRING",None),("badminid","STRING","fk")]),
         ("sales",[("Bookid","STRING","fk"),("bookprice","STRING",None),("insertdate","STRING",None)])],
    rel=[("Book.badminid","Users.uid"),("sales.Bookid","Book.Bookid")]),

  dict(slug="blood-bank", name="Blood Bank", cat="mobile", status="Completed", year=2022,
    summary="Android app to find blood donors by blood group and location.",
    tagline="Find a donor nearby and message them in the app",
    desc="An Android app that helps people find blood donors quickly. Donors create a profile with their blood group, location and photo. Anyone can search by blood group, save donors, rate them and start a conversation in the built-in chat.",
    github=gh+"Blood-Bank", tags=["Android (Java)","Firebase"],
    stack=dict(languages=["Java","XML"],frameworks=["Android SDK","Material Components"],databases=["Firebase Realtime Database","Firebase Storage"],tools=["Android Studio","Glide","Git"]),
    features=["Donor profiles with blood group, location, phone and photo","Search donors by blood group","Save donors to a personal list","In-app messaging between users","List of people you have messaged","Ratings and feedback"],
    challenges=[("Finding the right donor fast","Users are filtered by their blood group field, so a search shows only matching donors.")],
    arch=("Activities + Fragments","Android (Java, XML)","Firebase Authentication","Firebase Realtime Database + Storage"),
    erd=[("Users",[("hid","STRING","pk"),("uname","STRING",None),("blooadgroup","STRING",None),("location","STRING",None),("phone","STRING",None),("img","STRING",None)]),
         ("chats",[("messagesID","STRING","pk"),("senderID","STRING","fk"),("msgs","STRING",None)]),
         ("Saves",[("uid","STRING","fk"),("hid","STRING","fk")])],
    rel=[("chats.senderID","Users.hid"),("Saves.hid","Users.hid")]),

  dict(slug="note-app", name="Note App", cat="mobile", status="Completed", year=2022,
    summary="Offline notes app for Android using SQLite.",
    tagline="Write, edit and delete notes, with no internet needed",
    desc="A simple offline notes app. Notes are stored on the phone in a SQLite database. You can add a note, open and edit it, and long-press to delete it. If you leave without saving, the app asks whether to save or go back.",
    github=gh+"note_app", tags=["Android (Java)","SQLite"],
    stack=dict(languages=["Java","XML"],frameworks=["Android SDK"],databases=["SQLite"],tools=["Android Studio","Git"]),
    features=["Create, read, update and delete notes","Long-press a note to delete it, with a confirmation","Warning when leaving a note without saving","Bottom navigation between notes and new note","Works fully offline"],
    challenges=[("Losing a note by pressing back","The back button is overridden to show a dialog with save and back options, and empty fields are flagged before saving.")],
    arch=("Activities + Fragments","Android (Java, XML)","None (offline)","SQLite (SQLiteOpenHelper)"),
    erd=[("Notes",[("_id","INTEGER","pk"),("notetitle","VARCHAR",None),("Notebody","VARCHAR",None)])], rel=[],
    uml=dict(desc="Class diagram from the real code: three activities, a fragment, a list adapter, the note model and the SQLite helper. The flow shows adding, opening, updating and deleting a note.", **{"class":"/seed/projects/note-app/uml_class.webp"}, sequence="/seed/projects/note-app/flow.webp")),

  dict(slug="biography", name="Biography", cat="mobile", status="In Progress", year=2023,
    summary="Android app for registering people with their photo and details.",
    tagline="Register a person with a photo, saved on the device",
    desc="An Android app for creating short profiles. A user registers with a name, last name, age, phone number and a photo picked from the gallery. Everything, including the image, is saved in a local SQLite database. The home screen has an image slideshow and a navigation drawer.",
    github=gh+"biography", tags=["Android (Java)","SQLite"],
    stack=dict(languages=["Java","XML"],frameworks=["Android SDK","Material Components"],databases=["SQLite"],tools=["Android Studio","Glide","Git"]),
    features=["Registration form with input checks","Pick a photo from the gallery","Photos saved in SQLite as images (BLOB)","Image slideshow on the home screen","Navigation drawer and profile screen"],
    challenges=[("Saving a photo without a server","The picked image is compressed to PNG bytes and stored in a BLOB column next to the person's details.")],
    arch=("Activities + Fragments","Android (Java, XML)","None (offline)","SQLite (SQLiteOpenHelper)"),
    erd=[("userinfo",[("_id","INTEGER","pk"),("name","VARCHAR",None),("lastname","VARCHAR",None),("age","VARCHAR",None),("number","INTEGER",None),("image","BLOB",None)])], rel=[]),
]


q = lambda v: "NULL" if v is None else ("'" + str(v).replace("'","''") + "'")
pid = lambda slug: f"(SELECT id FROM projects WHERE slug = {q(slug)})"

def sql_for(p,i):
    o=[f"-- {p['name']}"]
    a=p["arch"]
    o.append("INSERT INTO projects (slug, sort_order, name, summary, category, status, icon_url, tagline, description, year_built, hero_url, github_url, live_url, demo_embed, demo_html, arch_pattern, arch_frontend, arch_backend, arch_database) VALUES")
    cover=f"/seed/covers/{p['slug']}.svg"
    icon=p.get("icon",cover); hero=p.get("hero",cover)
    o[-1]=o[-1].replace("arch_database)","arch_database, uml_description, uml_class_url, uml_sequence_url, uml_usecase_url)")
    u=p.get("uml",{})
    o.append("  ("+", ".join([q(p["slug"]),str(i),q(p["name"]),q(p["summary"]),q(p["cat"]),q(p["status"]),q(icon),q(p["tagline"]),q(p["desc"]),str(p["year"]),q(hero),q(p["github"]),q(p.get("live","")),"true" if p.get("embed") else "false","''",q(a[0]),q(a[1]),q(a[2]),q(a[3]),q(u.get("desc","")),q(u.get("class","")),q(u.get("sequence","")),q(u.get("usecase",""))])+");")
    def multi(table,cols,rows):
        if not rows: return
        o.append(f"INSERT INTO {table} ({', '.join(cols)}) VALUES")
        o.append(",\n".join("  ("+", ".join(r)+")" for r in rows)+";")
    multi("project_tags",["project_id","sort_order","tag"],[[pid(p["slug"]),str(n+1),q(t)] for n,t in enumerate(p["tags"])])
    multi("project_stack",["project_id","kind","sort_order","name"],[[pid(p["slug"]),q(k),str(n+1),q(x)] for k,l in p["stack"].items() for n,x in enumerate(l)])
    multi("project_features",["project_id","sort_order","content"],[[pid(p["slug"]),str(n+1),q(t)] for n,t in enumerate(p["features"])])
    multi("project_images",["project_id","kind","sort_order","url"],[[pid(p["slug"]),"'screen'",str(n+1),q(x)] for n,x in enumerate(p.get("screens",[]))])
    multi("project_challenges",["project_id","sort_order","problem","solution"],[[pid(p["slug"]),str(n+1),q(a),q(b)] for n,(a,b) in enumerate(p["challenges"])])
    for n,(tname,cols) in enumerate(p["erd"]):
        x,y=20+(n%3)*320,20+(n//3)*230
        o.append(f"INSERT INTO erd_tables (project_id, sort_order, name, pos_x, pos_y) VALUES ({pid(p['slug'])}, {n+1}, {q(tname)}, {x}, {y});")
        tid=f"(SELECT id FROM erd_tables WHERE project_id = {pid(p['slug'])} AND name = {q(tname)})"
        multi("erd_columns",["table_id","sort_order","name","data_type","key_type"],[[tid,str(c+1),q(cn),q(ct),q(ck)] for c,(cn,ct,ck) in enumerate(cols)])
    multi("erd_relations",["project_id","sort_order","from_ref","to_ref","kind"],[[pid(p["slug"]),str(n+1),q(f),q(t),"'N:1'"] for n,(f,t) in enumerate(p["rel"])])
    return "\n".join(o)

out="\n\n".join(sql_for(p,i+1) for i,p in enumerate(ALP))
open("projects_part.sql","w").write(out+"\n")
json.dump([dict(slug=p["slug"],name=p["name"],cat=p["cat"],tags=p["tags"]) for p in ALP],open("covers.json","w"))
print("ok",len(out))
