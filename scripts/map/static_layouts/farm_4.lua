return {
  version = "1.1",
  luaversion = "5.1",
  orientation = "orthogonal",
  width = 28,
  height = 28,
  tilewidth = 16,
  tileheight = 16,
  properties = {},
  tilesets = {
    {
      name = "tiles",
      firstgid = 1,
      tilewidth = 64,
      tileheight = 64,
      spacing = 0,
      margin = 0,
      image = "../../../../../tools/tiled/dont_starve/tiles.png",
      imagewidth = 512,
      imageheight = 1024,
      properties = {},
      tiles = {}
    }
  },
  layers = {
    {
      type = "tilelayer",
      name = "BG_TILES",
      x = 0,
      y = 0,
      width = 28,
      height = 28,
      visible = true,
      opacity = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        67, 0, 0, 0, 60, 0, 0, 0, 60, 0, 0, 0, 60, 0, 0, 0, 60, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        67, 0, 0, 0, 60, 0, 0, 0, 60, 0, 0, 0, 60, 0, 0, 0, 60, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        67, 0, 0, 0, 60, 0, 0, 0, 60, 0, 0, 0, 60, 0, 0, 0, 60, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0, 67, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      name = "FG_OBJECTS",
      visible = true,
      opacity = 1,
      properties = {},
      objects = {
        {
          name = "",
          type = "pighouse_farm",
          shape = "rectangle",
          x = 313,
          y = 64,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 8,
          y = 312,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 8,
          y = 345,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 8,
          y = 280,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 8,
          y = 265,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 8,
          y = 248,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 8,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 8,
          y = 329,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 8,
          y = 297,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 121,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 72,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 56,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 40,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 105,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 24,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 89,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 262,
          y = 363,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 279,
          y = 363,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 363,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 327,
          y = 363,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 311,
          y = 363,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 344,
          y = 363,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 360,
          y = 363,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 295,
          y = 363,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 312,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 329,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 265,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 375,
          y = 347,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 248,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 297,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 280,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 375,
          y = 8,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 359,
          y = 8,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 294,
          y = 8,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 326,
          y = 8,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 265,
          y = 9,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 310,
          y = 8,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 278,
          y = 8,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 343,
          y = 8,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 41,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 58,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 73,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 90,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 376,
          y = 26,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 95,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 249,
          y = 75,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 249,
          y = 92,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 249,
          y = 28,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 249,
          y = 60,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 249,
          y = 9,
          width = 0,
          height = 0,
          visible = true,
          properties = {
            ["data.health.percent"] = "1"
          }
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 249,
          y = 43,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 377,
          y = 120,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 377,
          y = 135,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 377,
          y = 103,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 377,
          y = 233,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 199,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 183,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 151,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 167,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 216,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 134,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 232,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 247,
          y = 362,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "wall_stone",
          shape = "rectangle",
          x = 8,
          y = 232,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "pig_guard_tower",
          shape = "rectangle",
          x = 79,
          y = 16,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 159,
          y = 160,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 226,
          y = 162,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 287,
          y = 162,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 96,
          y = 227,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 159,
          y = 226,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 225,
          y = 226,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 287,
          y = 227,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 98,
          y = 285,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 160,
          y = 286,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 225,
          y = 287,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        },
        {
          name = "",
          type = "berrybush",
          shape = "rectangle",
          x = 289,
          y = 285,
          width = 0,
          height = 0,
          visible = true,
          properties = {}
        }
      }
    }
  }
}
