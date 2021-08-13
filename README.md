# customer-vehicles

## How-To
### Requirements
You will need:
- git
- docker-compose & docker

### Setup
1. ```bash
   git clone git@github.com:emmahyde/customer-vehicles.git
    ```
1. ```bash
   cd customer-vehicles
   ```
1. ```bash
   docker-compose build
   ```
1. ```bash
   docker-compose run web rails db:setup
   ```

### Run Tests
Follow above instructions and then execute:
```bash
docker-compose run web rspec
```

### Run Server
Follow Setup instructions and then execute:
```bash
docker-compose up -d
```
The server is now running on `localhost:3000`.

## API Documentation
Load the schema in your [local Postman app](https://www.getpostman.com/collections/23285f6fa95c2b469be1),

Or view it on [a static site](https://documenter.getpostman.com/view/2221299/Tzz7PJU3#c0221860-a558-4d65-a9b4-02463d06aecf).

## Next Steps
There are some clear opportunities for improvement here.
- The Vehicle association makes DB queries that could be removed if a cache layer was implemented, or we could eager-load the associations in.
- More sort options for Customers, sort options at all for Vehicles.
- Expand the primary-vehicle functionality: right now the primary vehicle is only ever set the first time a vehicle is created for a customer. The intention here is to leave it very easily extendable, and the best way to do that is to support an association right off the bat, making some progress towards decoupling Customers and Vehicles.
    - Add more fine-grain control around the response to the client, i.e. list all vehicles, not just primary. The primary is set in this regard in order to more easily implement the initial requirement of sort on vehicle_type, but leaves the door open to extendability down the line.
- Better deletion practices: As of right now we could end up with bad data since we are not explicitly deleting associations upon destroying the parent Customer.
- It isn't necessarily DRY, it could be better abstracted, but for ease of digestion I wanted to leave it pretty friendly.
- Further test cases for edge cases and error handling, but as of right now it has 98.26% test coverage.
<img width="1618" alt="Screen Shot 2021-08-13 at 1 57 40 PM" src="https://user-images.githubusercontent.com/8183738/129400856-8d5c4590-a53b-478a-92f3-57255a9953cc.png">
