from fastapi import FastAPI
from tortoise.contrib.fastapi import register_tortoise

app = FastAPI(title="Clean API")


@app.get("/")
async def root() -> dict[str, str]:
    return {"message": "Hello World"}


def placeholder() -> bool:
    return True


register_tortoise(
    app,
    db_url="sqlite://:memory:",
    modules={"models": []},
    generate_schemas=True,
    add_exception_handlers=True,
)
