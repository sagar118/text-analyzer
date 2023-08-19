import requests

url = 'http://localhost:8080/predict'
# data = '13,000 people receive #wildfires evacuation orders in California'
# data = '@bbcmtd Wholesale Markets ablaze http://t.co/lHYXEOHY6C'
# data = 'there is a forest fire at spot pond, geese are fleeing across the street, I cannot save them all'
# data = 'Typhoon Soudelor kills 28 in China and Taiwan'
# data = 'India,Rape victim dies as she sets herself ablaze: A 16-year-old girl died of burn injuries as she set herself ablazeÛ_ http://t.co/UK8hNrbOob'
data = 'Just happened a terrible car crash'

result = requests.get(url, params={'data': data}).json()

print(result)
