---
draft: "true"
---

![[Pasted image 20250322134453.png]]
![[Pasted image 20250322134937.png]]
Opening the website, we see that the returned items are controlled by URL query parameters: price, price_op, and limit.

By adding a single quote to one of the parameters, we see that the application is vulnerable to SQL injection, as our input was directly used to query the database without sanitation. We know this is an error-based SQL injection by the error message in the response which reveals that we're working with a MySQL database. (Not displayed on the frontend).
![[Pasted image 20250322140309.png]]

app.py:
```

@app.route('/query')
def query():
    try:
        price = float(request.args.get('price') or '0.00')
    except:
        price = 0.0

    price_op = str(request.args.get('price_op') or '>')
    if not re.match(r' ?(=|<|<=|<>|>=|>) ?', price_op):
        return 'price_op must be one of =, <, <=, <>, >=, or > (with an

    # allow for at most one space on either side
    if len(price_op) > 4:
        return 'price_op too long', 400

    # I'm pretty sure the LIMIT clause cannot be used for an injection
    # with MySQL 9.x
    #
    # This attack works in v5.5 but not later versions
    # https://lightless.me/archives/111.html
    limit = str(request.args.get('limit') or '1')

    query = f"""SELECT /*{FLAG1}*/category, name, price, description FROM Menu WHERE price {price_op} {price} ORDER BY 1 LIMIT {limit}"""
    print('query:', query)

    if ';' in query:
        return 'Sorry, multiple statements are not allowed', 400

    try:
        cur = mysql.connection.cursor()
        cur.execute(query)
        records = cur.fetchall()
        column_names = [desc[0] for desc in cur.description]
        cur.close()
    except Exception as e:
        return str(e), 400

    result = [dict(zip(column_names, row)) for row in records]
    return jsonify(result)
```


Since we have the source code for this challenge, we're able to see the exact query executed:
`query = f"""SELECT /*{FLAG1}*/category, name, price, description FROM Menu WHERE price {price_op} {price} ORDER BY 1 LIMIT {limit}" print('query:', query)`

The source code also gives a useful hint about which parameter to try injecting at:
```
# I'm pretty sure the LIMIT clause cannot be used for an injection
# with MySQL 9.x
```
Since the limit parameter has a default value of 1, we don't actually need to provide a value.   Similarly, if we examine the price_op parameter, we see that the backed imposes a maximum length of 4 characters, meaning it's not useful to us for injecting. However, it also has a default value of '>' meaning we don't need to provide it at all.

This leaves us with the price parameter, which gets casted as a double... meaning if we provide anything else here, the server will throw an error and return an empty JSON object.

