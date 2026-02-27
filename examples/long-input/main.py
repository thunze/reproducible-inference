#!/usr/bin/env python

from openai import OpenAI

client = OpenAI(base_url="http://localhost:8080/v1", api_key="")

USER_MESSAGE = """\
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam mi diam, ornare at ante
id, condimentum fringilla odio. Quisque viverra leo vel nulla consectetur, ac aliquam
est imperdiet. Donec vel sapien feugiat, egestas magna non, rhoncus ipsum. Vestibulum
eleifend id nibh in convallis. Morbi accumsan sem eget ligula ornare viverra ut ut
elit. Morbi a eleifend magna, vel facilisis metus. Proin imperdiet accumsan tincidunt.

Integer tincidunt cursus fermentum. Morbi a venenatis elit. Nunc rutrum iaculis urna,
et dignissim lectus vehicula a. Proin faucibus et nisl vitae viverra. Vestibulum augue
ipsum, eleifend ut ligula eget, semper accumsan neque. Sed iaculis ligula sit amet
pretium efficitur. Aliquam condimentum eget nisl nec rutrum.

Etiam condimentum, quam a euismod porta, justo velit ultrices magna, vitae pharetra
purus lacus eget dolor. Aliquam finibus ligula posuere, dictum neque quis, placerat
odio. Cras posuere, arcu ut bibendum congue, nibh risus vehicula quam, vitae vulputate
lacus neque vitae nisi. Quisque viverra hendrerit est, in tempor orci molestie sit
amet. Pellentesque eget magna nec metus imperdiet vestibulum. Integer est odio,
efficitur vel pulvinar non, porttitor ut neque. Mauris ut viverra leo. Nunc sit amet
mauris ut magna mollis pharetra. Fusce vel tortor pharetra, aliquet leo sit amet,
sodales diam. Suspendisse quis tellus maximus, condimentum mi at, vulputate leo. Donec
in mollis metus, a elementum ligula. Nullam sed efficitur risus. Phasellus eu nunc
non tortor fermentum convallis ultricies vitae augue. Phasellus ante tellus, pulvinar
vitae accumsan sed, pharetra et libero.

Fusce euismod sapien vitae diam iaculis, ut gravida neque lacinia. Nam condimentum
mauris turpis, eu facilisis nisi feugiat eu. Pellentesque eget ornare dui, eu euismod
ante. Morbi pellentesque lectus eu purus viverra tincidunt. Aliquam eget semper lacus.
Duis nisl nisl, faucibus non mauris quis, venenatis blandit justo. Donec in tortor
vitae metus laoreet malesuada quis eget arcu. Ut pretium eros vitae scelerisque
facilisis. Suspendisse faucibus augue eu vehicula malesuada. Duis orci risus, accumsan
sit amet luctus sed, condimentum in nisl. Nulla elementum, arcu nec maximus faucibus,
nisi nulla scelerisque nunc, eget facilisis odio urna quis lorem. Quisque nec
sollicitudin massa. Etiam sed quam consequat, dapibus tellus in, gravida quam.
Curabitur feugiat tempus est, nec sodales neque posuere at. Morbi posuere nunc a purus
fringilla hendrerit.

Morbi nec nulla imperdiet, placerat risus sit amet, sodales ipsum. Ut eget
pellentesque odio. Curabitur volutpat, nisl in varius condimentum, quam magna
venenatis mauris, vel rhoncus felis libero eget augue. Cras porttitor lorem at
ultrices vestibulum. Praesent viverra mauris lacus, nec finibus arcu tincidunt sed.
Suspendisse scelerisque consectetur faucibus. Nullam porttitor sodales leo id lacinia.
Praesent placerat pellentesque fringilla.

---

What does this text express, on an emotional level?
"""

response = client.chat.completions.create(
    messages=[
        {
            "role": "user",
            "content": USER_MESSAGE,
        },
    ],
    model="",
)

print(response.choices[0].message.content)
